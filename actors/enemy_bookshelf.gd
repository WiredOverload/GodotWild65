extends BouncingCharacterBody3D

const ENEMY_BOOK: PackedScene = preload("res://actors/enemy_book.tscn")

const speed = 1.0
const weight = 5.0

enum State {
	SPAWN,
	WANDER,
	SNEEZE,
	DEATH,
}

@onready var player: Node3D = get_tree().get_first_node_in_group("Player")

var max_health = 1
var health = max_health

var state: State = State.SPAWN: set = set_state

@onready var bookshelf_model: GenericSignaller = $BookshelfModel
@onready var bookshelf = $BookshelfModel
@onready var bookshelf_anim: AnimationPlayer = $BookshelfModel/AnimationPlayer
@onready var bookshelf_motion_interpolator: MotionInterpolator3D = $BookshelfModel/MotionInterpolator3D
@onready var wander_turn_timer: Timer = $WanderTurnTimer
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var sneeze_timer: Timer = $SneezeTimer
@onready var page_sneeze: GPUParticles3D = $PageSneeze

func _ready() -> void:
	# spawn
	rotation.y = randf_range(0, TAU)
	bookshelf_anim.play("Spawn")
	bookshelf_anim.advance(0.0)
	await bookshelf_anim.animation_finished
	bookshelf_anim.play("Walk")
	velocity = basis.z
	state = State.WANDER

func _process(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	match state:
		State.WANDER:
			move_and_bounce()
	
	# arbitrary math to slowly turn to face forward
	rotation.y = rotate_toward(rotation.y, Vector3.MODEL_FRONT.signed_angle_to(velocity.normalized(), Vector3.UP), 3.0 * delta)

func set_state(v: State) -> void:
	match state:
		State.WANDER:
			wander_turn_timer.paused = true
	
	state = v
	
	match state:
		State.WANDER:
			bookshelf_anim.play("Walk")
			wander_turn_timer.paused = false
			wander_turn_timer.start()

func deal_damage(damage : int):
	if health > 0:
		health -= damage # TODO: Actually check this value.
		Globals.add_xp(weight)
		collision_shape_3d.disabled = true
		
		# fade to alpha zero and color to red
		var mesh_instance: MeshInstance3D = bookshelf.get_node("BookshelfArmature/Skeleton3D/Bookshelf")
		var material: BaseMaterial3D = mesh_instance.mesh["surface_0/material"].duplicate()
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mesh_instance["surface_material_override/0"] = material
		@warning_ignore("return_value_discarded")
		var tween := create_tween()
		tween.tween_interval(0.5)
		tween.tween_property(material, "albedo_color", Color(1, 0, 0, 0), 0.5)
		
		# despawn
		state = State.DEATH
		bookshelf_anim.play_backwards("Spawn")
		await bookshelf_anim.animation_finished
		queue_free()

func _on_wander_turn_timer_timeout() -> void:
	# Randomly rotate the direction the book is wandering in discrete angles
	velocity = velocity.rotated(Vector3.UP, randi_range(-1, 1) * PI / 8.0)
	wander_turn_timer.start(randf_range(3.0, 5.0))


func _on_sneeze_timer_timeout() -> void:
	if state != State.WANDER:
		return
	
	state = State.SNEEZE
	
	bookshelf_anim.play("Sneeze")
	assert((await bookshelf.event) == &"sneeze")
	await get_tree().process_frame
	
	if state != State.SNEEZE:
		return
	
	page_sneeze.emitting = true
	
	var book := ENEMY_BOOK.instantiate()
	#book.player = player
	get_parent().add_child(book)
	book.position = position + basis.z * 1.0
	book.rotation.y = rotation.y
	
	await bookshelf_anim.animation_finished
	
	if state != State.SNEEZE:
		return
	
	velocity = Vector3.MODEL_FRONT.rotated(Vector3.UP, randf_range(0, TAU))
	
	sneeze_timer.start(randf_range(3.0, 6.0))
	
	state = State.WANDER
