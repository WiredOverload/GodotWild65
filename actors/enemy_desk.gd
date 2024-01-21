extends BouncingCharacterBody3D

const speed = 1.0

enum State {
	SPAWN,
	WANDER,
	BARK,
	CHASE,
	DEATH,
}
var state: State = State.SPAWN: set = set_state

#@onready var player := get_tree().get_first_node_in_group("Player")

@onready var desk = $Desk
@onready var desk_anim: AnimationPlayer = desk.get_node("AnimationPlayer")
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var line_of_sight = $LineOfSight
@onready var aggro_range = $AggroRange
@onready var wander_turn_timer = $WanderTurnTimer


var _spawned: bool = false
var _target = null

func _ready() -> void:
	rotation.y = randf_range(0, TAU)
	desk_anim.play("Spawn")
	desk_anim.advance(0.0)
	await desk_anim.animation_finished
	desk_anim.play("Walk")
	velocity = basis.z
	_spawned = true
	state = State.WANDER


func _process(_delta: float) -> void:
	if not _spawned:
		return


func _physics_process(delta: float) -> void:
	match state:
		State.DEATH, State.SPAWN:
			return
		State.CHASE: 
			head_towards(_target.global_position)
			move_and_bounce()
		State.WANDER:
			move_and_bounce()
			
			if _target and check_los_to_body(_target):
				state = State.BARK
				head_towards(_target.global_position)
				rotation.y = Vector3.MODEL_FRONT.signed_angle_to(velocity.normalized(), Vector3.UP)
				desk_anim.play("Chomp")
				await Future.all_signals([desk_anim.animation_finished]).done
				state = State.CHASE
	
	# arbitrary math to slowly turn to face forward
	rotation.y = rotate_toward(rotation.y, Vector3.MODEL_FRONT.signed_angle_to(velocity.normalized(), Vector3.UP), 3.0 * delta)


func set_state(v: State) -> void:
	match state:
		State.WANDER, State.CHASE, State.BARK:
			wander_turn_timer.paused = true
	
	state = v
	
	match state:
		State.WANDER:
			desk_anim.play("Walk")
			wander_turn_timer.paused = false
			wander_turn_timer.start()
		State.CHASE:
			desk_anim.play("Walk")

func kill(room_clear: bool = false) -> void:
	if state == State.DEATH:
		return
	state = State.DEATH
	
	collision_shape_3d.disabled = true
	
	# fade to alpha zero and color to red
	var mesh_instance: MeshInstance3D = desk.get_node("DeskArmature/Skeleton3D/Desk")
	var material: BaseMaterial3D = mesh_instance.mesh["surface_0/material"].duplicate()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_instance["surface_material_override/0"] = material
	@warning_ignore("return_value_discarded")
	var tween := create_tween()
	tween.tween_interval(0.5)
	tween.tween_property(material, "albedo_color", Color(1, 0, 0, 0), 0.5)
	
	# despawn
	desk_anim.play_backwards("Spawn")
	await Future.all_signals([desk_anim.animation_finished]).done
	queue_free()


func head_towards(dest: Vector3) -> void:
	velocity = velocity.rotated(
		Vector3.UP,
		velocity.normalized().signed_angle_to(dest - global_position, Vector3.UP)
	)


func check_los_to_body(body) -> bool:
	line_of_sight.global_basis = Basis.IDENTITY
	line_of_sight.target_position = body.global_position - line_of_sight.global_position
	line_of_sight.force_raycast_update()			
	return line_of_sight.get_collider() == null

	
func _on_wander_turn_timer_timeout() -> void:
	# Randomly rotate the direction the book is wandering in discrete angles
	if state == State.WANDER:
		velocity = velocity.rotated(Vector3.UP, randi_range(-1, 1) * PI / 8.0)
	wander_turn_timer.start(randf_range(3.0, 5.0))


func _collision(other: PhysicsBody3D) -> void:
	if other.is_in_group("Player"):
		desk_anim.play("Chomp")
		other.deal_damage(2)


func _on_aggro_range_body_entered(body: Node3D):
	if body.is_in_group("Player") and _target == null:
		_target = body


func _on_aggro_range_body_exited(body):
	if body == _target:
		_target = null
		state = State.WANDER
