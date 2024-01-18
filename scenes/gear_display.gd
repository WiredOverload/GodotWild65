extends Node3D

@export var motion_blur_strength: float = 0.5

@onready var gear: Node3D = $gear
@onready var motion_blur: ColorRect = $MotionBlur

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var spin_speed := Globals.ball_power * 5.0
	gear.rotate_z(-delta * spin_speed)
	gear.scale.y = 1.0 - 4.0 * atan(abs(spin_speed) / 25.0) / TAU
	motion_blur.material["shader_parameter/strength"] = Engine.time_scale * motion_blur_strength * 4.0 * atan(abs(spin_speed) / 25.0) / TAU
