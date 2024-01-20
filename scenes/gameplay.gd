class_name Gameplay
extends Node3D

static var instance: Gameplay

const PLAYER_ROOT_SCENE: PackedScene = preload("res://scenes/player_root.tscn")

const STAGE_SCENES = [
	{ weight = 1.0, file = "res://scenes/stages/stage.tscn" },
]

const DEFAULT_SLOW_MOTION_SPEED = 2.0

signal slow_motion_complete(id: int)

var room_number := 0

var min_enemies := 3

@onready var world: Node3D = $World

var _stage
var _player_root

var _time_scale_targets: Array[float] = []
var _time_scale_durations: Array[float] = []
var _time_scale_speeds: Array[float] = []
var _time_scale_ids: Array[int] = []
var _time_scale_next_id: int = 1

func slow_motion(time_scale: float, adjustment_speed: float = DEFAULT_SLOW_MOTION_SPEED, effect_duration: float = -1) -> int:
	var i: int = _time_scale_targets.bsearch(time_scale)
	var id := _time_scale_next_id
	_time_scale_next_id += 1
	
	_time_scale_targets.insert(i, time_scale)
	_time_scale_durations.insert(i, effect_duration)
	_time_scale_speeds.insert(i, adjustment_speed)
	_time_scale_ids.insert(i, id)
	
	return id

func cancel_slow_motion(id: int) -> void:
	var i := _time_scale_ids.find(id)
	
	if i == -1:
		return
	
	if i == 0:
		Engine.time_scale = _time_scale_targets[0]
	
	_time_scale_targets.remove_at(i)
	_time_scale_durations.remove_at(i)
	_time_scale_speeds.remove_at(i)
	_time_scale_ids.remove_at(i)
	slow_motion_complete.emit(id)


func screen_shake(strength: float) -> void:
	screen_shake_vel(0.5 * Vector2.from_angle(randf_range(0, TAU)) * strength)

func screen_shake_vel(impulse: Vector2) -> void:
	_player_root.camera.screen_shake(0.5 * impulse)

func hit_stun() -> void:
	var id := slow_motion(0.01, 200.0, 0.2)
	while (await slow_motion_complete) != id:
		pass
	slow_motion(1.0, 200.0, 0.2)


func _enter_tree() -> void:
	assert(instance == null)
	instance = self

func _exit_tree() -> void:
	assert(instance == self)
	instance = null
	Engine.time_scale = 1.0

func _ready() -> void:
	create_room()

func create_room() -> void:
	var stage_info := _pick_random_stage()
	_stage = load(stage_info.file).instantiate()
	world.add_child(_stage)
	
	_player_root = PLAYER_ROOT_SCENE.instantiate()
	world.add_child(_player_root)
	_player_root.global_transform = _stage.player_spawn_point.global_transform
	
	_stage.ball = _player_root.ball
	
	_stage.player_exit.connect(_on_stage_player_exit)
	
	_player_root.entrance_walk_complete.connect(_stage.close_entrance)
	
	await _player_root.play_entrance_cutscene()
	
	_stage.spawn_enemies()

func _on_stage_player_exit():
	Globals.room_reset()
	Globals.difficulty += 1
	
	if Globals.difficulty > 20:
		get_tree().change_scene_to_file("res://scenes/win.tscn")
		return
	
	_stage.queue_free()
	_player_root.queue_free()
	
	world.remove_child(_stage)
	world.remove_child(_player_root)
	
	create_room()
	

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

#var _time_scale_targets: Array[float] = []
#var _time_scale_durations: Array[float] = []
#var _time_scale_speeds: Array[float] = []


var _last_process_time: float = Time.get_ticks_usec()

func _process(_delta: float) -> void:
	var now := Time.get_ticks_usec()
	var true_delta := (now - _last_process_time) / 1000000.0
	_last_process_time = now
	
	if not _time_scale_targets.is_empty():
		Engine.time_scale = move_toward(Engine.time_scale, _time_scale_targets[0], _time_scale_speeds[0] * true_delta)
		
		for i: int in range(_time_scale_targets.size() - 1, -1, -1):
			var d := _time_scale_durations[i]
			var id := _time_scale_ids[i]
			
			if d != -1:
				d -= true_delta
				
				if d <= 0.0:
					_time_scale_targets.remove_at(i)
					_time_scale_durations.remove_at(i)
					_time_scale_speeds.remove_at(i)
					_time_scale_ids.remove_at(i)
					slow_motion_complete.emit(id)
				else:
					_time_scale_durations[i] = d
	else:
		Engine.time_scale = move_toward(Engine.time_scale, 1.0, DEFAULT_SLOW_MOTION_SPEED * true_delta)
