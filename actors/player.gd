extends CharacterBody3D

enum State {
	NEUTRAL,
	THROWING,
	CATCHING
}

var move_speed: float = 5.0
var move_speed_throwing: float = 1.0

@export var ball: Ball

var state: State = State.NEUTRAL: set = set_state

var throw_speed: float = 0.0
var max_throw_speed: float = 20.0

var throw_accel: float = 10.0

#@onready var heart_controller = %HeartRoot
#var max_health := 5:
	#set(value):
		#if value > max_health:
			#heart_controller.add_heart()
		#max_health = value
#var health := max_health:
	#set(value):
		#if value < health:
			#heart_controller.hurt(health - value)
		#else:
			#heart_controller.heal(value - health)
		#health = value


@onready var ball_held_position: Marker3D = %BallHeldPosition
@onready var ball_back_position: Marker3D = %BallBackPosition


@onready var catch_area: Area3D = %CatchArea
@onready var spin_spark_particles: GPUParticles3D = %SpinSparkParticles
@onready var vibrate_timer: Timer = $VibrateTimer
@onready var invuln_timer: Timer = $InvulnTimer
@onready var mesh = $PlayerModelTeacher/PlayerArmature/Skeleton3D/Player

@onready var animation_tree: AnimationTree = $AnimationTree

@onready var hold_distance: float = Vector3(ball_held_position.position.x, 0, ball_held_position.position.z).length()

func _ready() -> void:
	assert(ball)
	ball.grab(ball_back_position)
	deactivate_catcher()
	

func set_state(v: State) -> void:
	# exiting state
	match state:
		State.CATCHING:
			deactivate_catcher()
		State.THROWING:
			ball.held_marker = ball_back_position
			spin_spark_particles.emitting = false
			Gameplay.instance.set_time_scale(1.0, 0.01)
			vibrate_timer.stop()
	
	state = v
	
	# entering state
	match state:
		State.THROWING:
			ball.held_marker = ball_held_position
		State.CATCHING:
			activate_catcher()

func _process(delta: float) -> void:
	match state:
		State.NEUTRAL:
			_update_walk_animation(delta)
			
			if Input.is_action_just_pressed("action"):
				if ball.is_held:
					state = State.THROWING
				else:
					state = State.CATCHING
		State.THROWING:
			if Input.is_action_pressed("action"):
				throw_speed = clampf(throw_speed + delta * throw_accel, 0.0, max_throw_speed)
				Globals.gear = floor(throw_speed / 20)
				if not spin_spark_particles.emitting and is_equal_approx(throw_speed, max_throw_speed):
					spin_spark_particles.restart()
					Gameplay.instance.set_time_scale(0.3, 0.1)
					vibrate_timer.start()
				if spin_spark_particles.emitting and not is_equal_approx(throw_speed, max_throw_speed):
					spin_spark_particles.emitting = false
					Gameplay.instance.set_time_scale(1.0, 0.01)
					vibrate_timer.stop()
			else:
				# Release!
				
				ball.throw(throw_speed * basis.z)
				throw_speed = 0.0
				state = State.NEUTRAL
		State.CATCHING:
			_update_walk_animation(delta)
			
			if Input.is_action_pressed("action"):
				var ob := catch_area.get_overlapping_bodies()
				assert(ob.size() < 2)
				if ob.size() == 1:
					assert(ob[0] == ball)
					throw_speed = ball.current_speed
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
			
			move_and_slide()
		
		State.THROWING:
			rotation.y += delta * throw_speed / hold_distance
			
			if direction:
				velocity.x = direction.x * move_speed_throwing
				velocity.z = direction.z * move_speed_throwing
			else:
				velocity.x = move_toward(velocity.x, 0, move_speed)
				velocity.z = move_toward(velocity.z, 0, move_speed)
			
			move_and_slide()
			
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


func _on_vibrate_timer_timeout() -> void:
	Gameplay.instance.screen_shake(7.0)

func hit(damage):
	if invuln_timer.is_stopped() && Globals.health > 0:
		print("HIT")
		Globals.health -= damage
		if Globals.health < 1:
			print("dead")
			mesh.mesh.surface_get_material(0).albedo_color = Color.DARK_MAGENTA
			$DeathTimer.start()
		else:
			mesh.mesh.surface_get_material(0).albedo_color = Color.WHITE
			invuln_timer.start()


func _on_invuln_timer_timeout() -> void:
	mesh.mesh.surface_get_material(0).albedo_color = Color("ff79ff")


func _on_death_timer_timeout() -> void:
	print("SCENE CHANGE")
	get_tree().change_scene_to_file("res://scenes/lose.tscn")
