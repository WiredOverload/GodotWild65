extends BouncingCharacterBody3D

const MAX_BOUNCES := 1

enum State {
	HELD,
	MOVING,
}

@export var mesh: Mesh = preload("res://character_models/meshes/backpack_BackpackMesh.res")

var state: State = State.MOVING: set = set_state

var held_marker: Node3D

var is_held: bool:
	get: return state == State.HELD

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var motionInterpolator := $MeshInstance3D/MotionInterpolator3D

var current_speed: float:
	get: return Globals.ball_power * 5.0

func _ready() -> void:
	mesh_instance_3d.mesh = mesh

func _physics_process(delta: float) -> void:
	match state:
		State.HELD:
			global_transform = held_marker.global_transform
			return
		State.MOVING:
			velocity = velocity.normalized() * current_speed
			if velocity.length() < .01:
				var offset = Transform3D()
				offset.origin = Vector3(0, -.5, 0)
				motionInterpolator.offset_transform = offset
			else:
				motionInterpolator.offset_transform = Transform3D()
			move_and_bounce()
			rotation.y = Vector3.MODEL_FRONT.signed_angle_to(velocity.normalized(), Vector3.UP)

# called when move_and_bounce() hits something
func _on_bounce(collision: KinematicCollision3D) -> void:
	var normal := collision.get_normal()
	Gameplay.instance.screen_shake_vel(-Vector2(normal.x, normal.z).normalized() * velocity.length())
	if not collision.get_collider().is_in_group("Player"):
		Globals.decay_ball_power()

func _collision(other: PhysicsBody3D) -> void:
	if other.is_in_group("Enemy"):
		var status = other.get_node_or_null("EnemyStatus")
		if status is EnemyStatus:
			if Globals.current_gear >= status.required_gear_level:
				status.current_health -= 1 + Globals.damage_bonus
				Gameplay.instance.hit_stun()
				Gameplay.instance.spawn_shock(global_position)
				# TODO: sfx dong
			else:
				Gameplay.instance.spawn_shock(global_position) # TODO: make visually sharper like "ping"
				# TODO: sfx ping

func set_state(v: State) -> void:
	match state:
		State.HELD:
			$CollisionShape3D.disabled = false
		State.MOVING:
			velocity = Vector3.ZERO
	
	state = v
	
	match state:
		State.HELD:
			$CollisionShape3D.disabled = true

func grab(marker: Node3D) -> void:
	state = State.HELD
	held_marker = marker
	# TODO: sfx tch

func throw(direction: Vector3) -> void:
	state = State.MOVING
	velocity = direction * current_speed
	# TODO: sfx yeet
