extends Camera3D

@export_range(0.0, 1.0) var shake_spring_coef: float = 0.1
@export_range(0.0, 1.0) var shake_spring_damp: float = 0.3

var shake_offset: Vector2:
	get: return Vector2(h_offset, v_offset)
	set(v): h_offset = v.x; v_offset = v.y

var shake_velocity: Vector2

func screen_shake(impulse: Vector2) -> void:
	shake_velocity += impulse

func _ready() -> void:
	assert(0.0 <= shake_spring_coef)
	assert(shake_spring_coef < shake_spring_damp)
	assert(shake_spring_damp <= 1.0)

func _process(delta: float) -> void:
	var shake_accel := - pow(1.0 / delta, 2) * shake_spring_coef * shake_offset - (1.0 / delta) * shake_spring_damp * shake_velocity
	shake_offset += delta * shake_velocity
	shake_velocity += delta * shake_accel
