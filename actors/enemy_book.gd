extends BouncingCharacterBody3D

const speed = 1.0

enum State {
	SPAWN,
	WANDER,
	DEATH,
}

var state: State = State.SPAWN

@onready var book = $Book
@onready var book_anim: AnimationPlayer = book.get_node("AnimationPlayer")
@onready var book_motion_interpolator: MotionInterpolator3D = $Book/MotionInterpolator3D
@onready var page_cough: GPUParticles3D = $Book/PageCough
@onready var page_death: GPUParticles3D = $PageDeath
@onready var wander_turn_timer: Timer = $WanderTurnTimer
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var enemy_status: EnemyStatus = $EnemyStatus

var _spawned: bool = false

func _ready() -> void:
	assert(page_cough)
	# spawn
	rotation.y = randf_range(0, TAU)
	book_anim.play("Spawn")
	book_anim.advance(0.0)
	await book_anim.animation_finished
	state = State.WANDER
	book_anim.play("Flap")
	velocity = basis.z
	_spawned = true

func _process(_delta: float) -> void:
	if state != State.WANDER:
		return
	
	# Make the book's 3d model appear to drift randomly (for da juice)
	book_motion_interpolator.offset_transform.origin = 0.2 * Vector3(
		sin(2.3 * Time.get_ticks_msec() / 1000.0),
		sin(2.7 * Time.get_ticks_msec() / 1000.0),
		sin(2.5 * Time.get_ticks_msec() / 1000.0))
	book_motion_interpolator.offset_transform.basis = Basis.from_euler(0.2 * Vector3(
		sin(2.3 * Time.get_ticks_msec() / 1000.0),
		sin(2.7 * Time.get_ticks_msec() / 1000.0),
		sin(2.5 * Time.get_ticks_msec() / 1000.0)))

func _physics_process(delta: float) -> void:
	if state != State.WANDER:
		return
	
	move_and_bounce()
	# arbitrary math to slowly turn to face forward
	rotation.y = rotate_toward(rotation.y, Vector3.MODEL_FRONT.signed_angle_to(velocity.normalized(), Vector3.UP), 3.0 * delta)


func _on_book_event(what: StringName) -> void:
	# emitted from the animation playback
	match what:
		&"cough":
			page_cough.emitting = true


func _on_wander_turn_timer_timeout() -> void:
	if state != State.WANDER:
		return
	
	# Randomly rotate the direction the book is wandering in discrete angles
	velocity = velocity.rotated(Vector3.UP, randi_range(-1, 1) * PI / 8.0)
	wander_turn_timer.start(randf_range(3.0, 5.0))


func _collision(other: PhysicsBody3D) -> void:
	if other.is_in_group("Player"):
		other.deal_damage(1)


func kill(room_clear: bool = false) -> void:
	if state == State.DEATH:
		return
	state = State.DEATH
	
	if not room_clear:
		$Ouch.play()
	page_death.emitting = true
	collision_shape_3d.disabled = true
	
	# fade to alpha zero and color to red
	var mesh_instance: MeshInstance3D = book.get_node("BookArmature/Skeleton3D/Book")
	var material: BaseMaterial3D = mesh_instance.mesh["surface_0/material"].duplicate()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_instance["surface_material_override/0"] = material
	@warning_ignore("return_value_discarded")
	var tween := create_tween()
	tween.tween_interval(0.5)
	tween.tween_property(material, "albedo_color", Color(1, 0, 0, 0), 0.5)
	
	# despawn
	book_anim.play_backwards("Spawn")
	await Future.all_signals([page_death.finished, book_anim.animation_finished]).done
	if page_cough.emitting:
		await page_cough.finished
	queue_free()
	
