class_name Gameplay
extends Node3D

static var instance: Gameplay

@onready var gameplay_camera: Camera3D = $GameplayCamera

var _engine_time_scale: float:
	get: return Engine.time_scale
	set(v): Engine.time_scale = v

var _time_scale_tween: Tween

func set_time_scale(v: float, dur: float) -> void:
	if _time_scale_tween:
		_time_scale_tween.kill()
	_time_scale_tween = create_tween()
	_time_scale_tween.tween_property(self, "_engine_time_scale", v, dur)


func screen_shake(strength: float) -> void:
	screen_shake_vel(Vector2.from_angle(randf_range(0, TAU)) * strength)

func screen_shake_vel(impulse: Vector2) -> void:
	gameplay_camera.screen_shake(impulse)

func _enter_tree() -> void:
	assert(instance == null)
	instance = self

func _exit_tree() -> void:
	assert(instance == self)
	instance = null
	Engine.time_scale = 1.0

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
