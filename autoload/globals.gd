extends Node

signal stat_changed

# per-run stats
var health := 3: set = set_health
var max_health := 5: set = set_max_health
var spin_acceleration := 1
var max_stamina := 1
var damage_bonus := 0
var spin_slowmo_modifier := 1
var difficulty := 0: set = set_difficulty

var ball_power_retention: float = 0.5

# per-room stats
var ball_power_max: float = 1.0: set = set_ball_power_max
var ball_power: float = 0.0: set = set_ball_power

# derived stats
var current_gear: int:
	get: return floori(snappedf(ball_power, 0.01))

var current_max_gear: int:
	get: return floori(snappedf(ball_power_max, 0.01))

func reset():
	health = 3
	max_health = 5
	difficulty = 0
	ball_power_retention = 0.5
	room_reset()

func room_reset():
	ball_power_max = 1.0
	ball_power = 0.0


func charge_ball_power(amount: float) -> void:
	ball_power = clampf(ball_power + amount, 0.0, ball_power_max)

func decay_ball_power(amount: float = 1.0 - ball_power_retention) -> void:
	ball_power = clampf(ball_power - amount, 0.0, ball_power_max)


func add_xp(amount: float) -> void:
	ball_power_max += amount


func set_health(v: int) -> void:
	print("set_health: %s -> %s" % [health, v])
	health = v
	stat_changed.emit()

func set_max_health(v: int) -> void:
	print("set_max_health: %s -> %s" % [max_health, v])
	max_health = v
	stat_changed.emit()

func set_difficulty(v: int) -> void:
	print("set_difficulty: %s -> %s" % [difficulty, v])
	difficulty = v
	stat_changed.emit()

func set_ball_power_max(v: float) -> void:
	print("set_ball_power_max: %s -> %s" % [ball_power_max, v])
	ball_power_max = v
	stat_changed.emit()

func set_ball_power(v: float) -> void:
	#print("set_ball_power: %s -> %s" % [ball_power, v])
	ball_power = v
	stat_changed.emit()




# debug overlay
var _overlay

func _unhandled_key_input(event: InputEvent) -> void:
	if event.pressed and event.physical_keycode == KEY_F1:
		if not _overlay:
			_overlay = load("res://autoload/globals/globals_overlay.tscn").instantiate()
			get_parent().add_child(_overlay)
		else:
			_overlay.visible = not _overlay.visible
	
