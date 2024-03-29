extends CharacterBody3D

const PLAYER_MODEL_SCENES: Dictionary = {
	TEACHER = preload("res://character_models/player_teacher/player_teacher.blend"),
	WITCH = preload("res://character_models/player_witch/player_witch.blend"),
}

const SPIN_SPEED = 6.0

enum State {
	NEUTRAL = 0,
	THROWING = 1,
	CATCHING = 2,
	DISABLED = 3,
}

signal action_pressed

@export_enum("TEACHER", "WITCH") var model_name: String = "TEACHER"

var base_move_speed: float = 5.0
var base_move_speed_throwing: float = 1.0
var throw_accel: float = 10.0

var state: State = State.NEUTRAL: set = set_state

var explosion = preload("res://UI/explosion.tscn")

@onready var ball = get_tree().get_first_node_in_group("Ball")

@onready var player_model = $PlayerModel

@onready var model_transform: Marker3D = $ModelTransform
@onready var ball_held_position: Marker3D = %BallHeldPosition
@onready var ball_back_position: Marker3D = %BallBackPosition


@onready var catch_area: Area3D = %CatchArea
@onready var spin_spark_particles: GPUParticles3D = %SpinSparkParticles
@onready var vibrate_timer: Timer = $VibrateTimer
@onready var invuln_timer: Timer = $InvulnTimer

@onready var animation_tree: AnimationTree = $AnimationTree


@onready var hold_distance: float = Vector3(ball_held_position.position.x, 0, ball_held_position.position.z).length()

var mesh

var move_speed: float:
	get: return base_move_speed * Globals.walk_speed_multiplier * (1 - (int((state == State.NEUTRAL) && (ball.state == 0)) * .5))

var move_speed_throwing: float:
	get: return base_move_speed_throwing * Globals.walk_speed_multiplier

var _throw_slomo_id: int = 0

var _spin_speed: float:
	get: return Globals.ball_power * SPIN_SPEED * Globals.charge_speed_base * Globals.charge_speed_multiplier

func _ready() -> void:
	assert(model_name in PLAYER_MODEL_SCENES)
	
	var placeholder: InstancePlaceholder = player_model
	var motintp: MotionInterpolator3D = placeholder.get_node("MotionInterpolator3D")
	player_model = placeholder.create_instance(true, PLAYER_MODEL_SCENES[model_name])
	motintp.reparent(player_model)
	
	mesh = player_model.get_node("PlayerArmature/Skeleton3D/Player")
	
	if ball:
		ball.grab(ball_back_position)
	deactivate_catcher()
	



func _exit_tree() -> void:
	if Gameplay.instance:
		Gameplay.instance.cancel_slow_motion(_throw_slomo_id)


func set_state(v: State) -> void:
	# exiting state
	match state:
		State.NEUTRAL:
			model_transform.basis = Basis.IDENTITY
		State.CATCHING:
			model_transform.basis = Basis.IDENTITY
			deactivate_catcher()
		State.THROWING:
			ball.held_marker = ball_back_position
			spin_spark_particles.emitting = false
			Gameplay.instance.cancel_slow_motion(_throw_slomo_id)
			_throw_slomo_id = 0
			vibrate_timer.stop()
		State.DISABLED:
			$CollisionShape3D.disabled = false
	
	state = v
	
	# entering state
	match state:
		State.THROWING:
			ball.held_marker = ball_held_position
		State.CATCHING:
			activate_catcher()
		State.DISABLED:
			$CollisionShape3D.disabled = true

func _process(delta: float) -> void:
	if ball == null:
		ball = get_tree().get_first_node_in_group("Ball")
		if ball:
			ball.grab(ball_back_position)
	
	match state:
		State.NEUTRAL:
			_update_walk_animation(delta)
			
			if Input.is_action_just_pressed("action"):
				if ball and ball.is_held:
					state = State.THROWING
				else:
					action_pressed.emit()
					state = State.CATCHING
		State.THROWING:
			if Input.is_action_pressed("action"):
				Globals.charge_ball_power(delta * Globals.charge_speed_base * Globals.charge_speed_multiplier)
				
				if not spin_spark_particles.emitting and Globals.ball_power == Globals.ball_power_max:
					spin_spark_particles.restart()
					_throw_slomo_id = Gameplay.instance.slow_motion(0.3 * Globals.spin_slowmo_modifier, 2.0)
					vibrate_timer.start()
				if spin_spark_particles.emitting and Globals.ball_power != Globals.ball_power_max:
					spin_spark_particles.emitting = false
					Gameplay.instance.cancel_slow_motion(_throw_slomo_id)
					_throw_slomo_id = 0
					vibrate_timer.stop()
			else:
				# Release!
				
				ball.throw(basis.z)
				state = State.NEUTRAL
		State.CATCHING:
			_update_walk_animation(delta)
			
			if Input.is_action_pressed("action"):
				var ob := catch_area.get_overlapping_bodies()
				assert(ob.size() < 2)
				if ob.size() == 1:
					assert(ob[0] == ball)
					ball.grab(ball_held_position)
					state = State.THROWING
			else:
				state = State.NEUTRAL

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	match state:
		State.NEUTRAL, State.CATCHING:
			if direction:
				velocity.x = direction.x * move_speed
				velocity.z = direction.z * move_speed
				rotation.y = Vector3.MODEL_FRONT.signed_angle_to(direction, Vector3.UP)
			else:
				velocity.x = move_toward(velocity.x, 0, move_speed)
				velocity.z = move_toward(velocity.z, 0, move_speed)
			
			model_transform.global_basis = Basis.from_euler(Vector3(-TAU / 16.0, 0, 0)) * global_basis
			model_transform.global_position = Vector3(0, 0, 0.25) + global_position
			
			if move_and_slide():
				_handle_move_and_slide_collision()
		
		State.THROWING:
			if Globals.current_gear == Globals.current_max_gear:
				rotation.y += delta * 5.0 / hold_distance
			else:
				rotation.y += delta * _spin_speed / hold_distance
			
			if direction:
				velocity.x = direction.x * move_speed_throwing
				velocity.z = direction.z * move_speed_throwing
			else:
				velocity.x = move_toward(velocity.x, 0, move_speed)
				velocity.z = move_toward(velocity.z, 0, move_speed)
			
			model_transform.global_basis = Basis.from_euler(Vector3(-TAU / 16.0, 0, 0)) * global_basis
			model_transform.global_position = Vector3(0, 0, 0.25) + global_position
			
			if move_and_slide():
				_handle_move_and_slide_collision()
			
			ball.global_transform = ball_held_position.global_transform


func _update_walk_animation(delta: float) -> void:
	var cur_walk_blend: float = animation_tree["parameters/StateMachine/Walk/Blend/blend_position"]
	cur_walk_blend = move_toward(cur_walk_blend, velocity.length() / move_speed, delta / 0.2)
	animation_tree["parameters/StateMachine/Walk/Blend/blend_position"] = cur_walk_blend
	
	var cur_catch_blend: float = animation_tree["parameters/CatchBlend/blend_amount"]
	cur_catch_blend = move_toward(cur_catch_blend, 1.0 if state == State.CATCHING else 0.0, delta / 0.02)
	animation_tree["parameters/CatchBlend/blend_amount"] = cur_catch_blend


func activate_catcher() -> void:
	catch_area.monitoring = true

func deactivate_catcher() -> void:
	catch_area.monitoring = false

func _handle_move_and_slide_collision() -> void:
	for i: int in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		if has_method(&"_collision"):
			call(&"_collision", collision.get_collider())
		if collision.get_collider().has_method(&"_collision"):
			collision.get_collider().call(&"_collision", self)

func _on_vibrate_timer_timeout() -> void:
	Gameplay.instance.screen_shake(7.0)

func deal_damage(damage):
	if invuln_timer.is_stopped() && Globals.health > 0:
		print("HIT")
		Globals.health -= damage
		if Globals.health < 1:
			print("dead")
			mesh.mesh.surface_get_material(0).albedo_color = Color.DARK_RED
			$DeathTimer.start()
			var explode = explosion.instantiate()
			add_child(explode)
			explode.position = Vector3(0, 1.5, 0)
		else:
			mesh.mesh.surface_get_material(0).albedo_color = Color.RED * 1.5
			invuln_timer.start()


func _on_invuln_timer_timeout() -> void:
	mesh.mesh.surface_get_material(0).albedo_color = Color.WHITE


func _on_death_timer_timeout() -> void:
	mesh.mesh.surface_get_material(0).albedo_color = Color.WHITE
	print("SCENE CHANGE")
	get_tree().change_scene_to_file("res://scenes/lose.tscn")

