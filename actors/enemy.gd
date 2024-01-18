extends CharacterBody3D


const speed = 1.0
const weight = 5.0
var max_health = 1
var health = max_health
var damage = 1
@onready var mesh : MeshInstance3D = $MeshInstance3D
@onready var player = $"../Player"

func _ready() -> void:
	velocity = Vector3(randf(), 0, randf())

func _physics_process(delta: float) -> void:
	var collision : KinematicCollision3D
	
	if player:
		velocity = (player.position - position).normalized() * speed
	
	if health > 0:
		collision = move_and_collide(velocity * delta)
	
	if collision:
		if collision.get_collider().is_in_group("Player"):
			collision.get_collider().deal_damage(damage)

func deal_damage(damage : int):
	if health > 0:
		health -= damage
		mesh.mesh.surface_get_material(0).albedo_color = Color.BLACK
		Globals.bag_raw_speed_max += weight
