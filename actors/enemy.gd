extends CharacterBody3D


const speed = 1.0
const weight = 5.0
var max_health = 1
var health = max_health
var mesh : MeshInstance3D
var player

func _ready() -> void:
	velocity = Vector3(randf(), 0, randf())
	player = $"../Player"
	mesh = $MeshInstance3D

func _physics_process(delta: float) -> void:
	
	if player:
		velocity = (player.position - position).normalized() * speed
	
	if health > 0:
		move_and_slide()

func hit(damage : int):
	if health > 0:
		health -= damage
		mesh.mesh.surface_get_material(0).albedo_color = Color.BLACK
		player.max_throw_speed += weight
