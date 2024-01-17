class_name Gameplay
extends Node3D

static var instance: Gameplay

const PLAYER_ROOT_SCENE: PackedScene = preload("res://scenes/player_root.tscn")

const STAGE_SCENES = [
	{ weight = 1.0, file = "res://scenes/stages/stage.tscn" },
]

var room_number := 0

var min_enemies := 3

@onready var world: Node3D = $World

var _stage
var _player_root

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
	screen_shake_vel(0.5 * Vector2.from_angle(randf_range(0, TAU)) * strength)

func screen_shake_vel(impulse: Vector2) -> void:
	_player_root.camera.screen_shake(0.5 * impulse)

func hit_stun() -> void:
	if _time_scale_tween:
		_time_scale_tween.pause()
	_engine_time_scale = 0.01
	var s := Time.get_ticks_usec()
	while Time.get_ticks_usec() - s < 100000:
		await get_tree().process_frame
	_engine_time_scale = 1.0
	_time_scale_tween.play()
	


func _enter_tree() -> void:
	assert(instance == null)
	instance = self

func _exit_tree() -> void:
	assert(instance == self)
	instance = null
	Engine.time_scale = 1.0

func _ready() -> void:
	var stage_info := _pick_random_stage()
	_stage = load(stage_info.file).instantiate()
	world.add_child(_stage)
	
	_player_root = PLAYER_ROOT_SCENE.instantiate()
	world.add_child(_player_root)
	_player_root.global_transform = _stage.player_spawn_point.global_transform
	
	await _player_root.play_entrance_cutscene()
	
	_stage.spawn_enemies()

func _pick_random_stage() -> Dictionary:
	var total_weight: float = 0.0
	for s: Dictionary in STAGE_SCENES:
		total_weight += s.weight
	var roll := randf_range(0.0, total_weight)
	for s: Dictionary in STAGE_SCENES:
		roll -= s.weight
		if roll <= 0.0:
			return s
	assert(false)
	return STAGE_SCENES[0]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
