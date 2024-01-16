class_name Ball
extends BouncingCharacterBody3D

const MAX_BOUNCES := 1

enum State {
	HELD,
	MOVING,
}

@export var mesh: Mesh = preload("res://character_models/meshes/backpack_BackpackMesh.res")

var current_speed = 15.0

var state: State = State.MOVING

var held_marker: Node3D

var is_held: bool:
	get: return state == State.HELD

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	mesh_instance_3d.mesh = mesh

func _physics_process(delta: float) -> void:
	match state:
		State.HELD:
			global_transform = held_marker.global_transform
			return
		State.MOVING:
			move_and_bounce()
			rotation.y = Vector3.MODEL_FRONT.signed_angle_to(velocity.normalized(), Vector3.UP)

# called when move_and_bounce() hits something
func _on_bounce(collision: KinematicCollision3D) -> void:
	var normal := collision.get_normal()
	
	Gameplay.instance.screen_shake_vel(-Vector2(normal.x, normal.z).normalized() * velocity.length())
	
	if collision.get_collider().is_in_group("Enemy"):
		collision.get_collider().hit(1)
		Gameplay.instance.hit_stun()

func grab(marker: Node3D) -> void:
	state = State.HELD
	held_marker = marker

func throw(vel: Vector3) -> void:
	state = State.MOVING
	current_speed = vel.length()
	velocity = vel
