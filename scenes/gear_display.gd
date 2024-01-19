extends Node3D

@export var motion_blur_strength: float = 0.5
@export var squash_strength: float = 0.5
@export var wobble_strength: float = 0.1

@onready var gear: Node3D = $GearGimbal/gear
@onready var gear_gimbal: Node3D = $GearGimbal
@onready var motion_blur: ColorRect = $MotionBlur

var time: float = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	
	var spin_speed := Globals.ball_power * 5.0
	gear.rotate_z(-delta * spin_speed)
	gear.scale.y = 1.0 - squash_strength * 4.0 * atan(abs(spin_speed) / 25.0) / TAU
	
	var wobble_speed := 1.0 + Globals.current_gear
	gear_gimbal.rotation.x = wobble_strength * sin(wobble_speed * time / (TAU / 4.0))
	gear_gimbal.rotation.y = wobble_strength * sin(wobble_speed * time)
	
	motion_blur.material["shader_parameter/strength"] = Engine.time_scale * motion_blur_strength * 4.0 * atan(abs(spin_speed) / 25.0) / TAU
