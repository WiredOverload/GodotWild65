extends CharacterBody3D

const speed = 1.0
const weight = 5.0
var max_health = 1
var health = max_health

@export var player: Node3D

@onready var book: Node3D = $Book
@onready var book_anim: AnimationPlayer = book.get_node("AnimationPlayer")
@onready var page_cough: GPUParticles3D = $PageCough

func _ready() -> void:
	book_anim.play("Spawn")
	await book_anim.animation_finished
	book_anim.play("Flap")
	velocity = Vector3(randf(), 0, randf())

func _physics_process(delta: float) -> void:
	if health > 0:
		move_and_slide()
	rotation.y = move_toward(rotation.y, Vector3.MODEL_FRONT.signed_angle_to(velocity.normalized(), Vector3.UP), delta)

func hit(damage : int):
	if health > 0:
		health -= damage
		player.max_throw_speed += weight
