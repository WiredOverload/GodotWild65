extends Area3D


@onready var fireball_model: Node3D = $FireballModel
@onready var mesh_instance: MeshInstance3D = $FireballModel/Fireball
@onready var explosion: GPUParticles3D = $FireballModel/Explosion

var velocity: Vector3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	global_position += velocity * delta
	rotation.y = Vector3.MODEL_FRONT.signed_angle_to(velocity.normalized(), Vector3.UP)

func _on_flicker_timer_timeout() -> void:
	mesh_instance["blend_shapes/Flicker"] = float(randi_range(0, 1))
	fireball_model.rotation.z = randf_range(0, TAU)


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.deal_damage(1)
	explosion.reparent(get_parent())
	explosion.emitting = true
	explosion.finished.connect(explosion.queue_free)
	queue_free()
