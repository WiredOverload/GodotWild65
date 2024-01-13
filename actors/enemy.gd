extends CharacterBody3D


const speed = 1.0
var max_health = 1
var health = max_health
var target

func _ready() -> void:
	velocity = Vector3(randf(), 0, randf())
	target = $"../Player"

func _physics_process(delta: float) -> void:
	
	if target:
		velocity = (target.position - position).normalized() * speed
	
	if health > 0:
		move_and_slide()

func hit(damage : int):
	health -= damage
	var mesh := $MeshInstance3D
	mesh.mesh.surface_get_material(0).albedo_color = Color.BLACK
