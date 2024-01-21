extends Node

signal stat_changed

const XP_SNAP = 0.01

# persistent
var selected_character: String = "TEACHER"

# per-run stats
var health := 3: set = set_health
var max_health := 3: set = set_max_health
#var max_stamina := 1
var damage_bonus := 1.0
var spin_slowmo_modifier := 1.0
var difficulty := 0: set = set_difficulty

var charge_speed_base: float = 1.0
var ricochets_base: int = 0

var ball_power_retention: float = 0.5 # don't forget to copy changes here to the reset()
var walk_speed_multiplier: float = 1.0
var charge_speed_multiplier: float = 1.0
var xp_multiplier: float = 2.0

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
	max_health = 3
	difficulty = 0
	damage_bonus = 1.0
	spin_slowmo_modifier = 1.0
	ball_power_retention = 0.5
	walk_speed_multiplier = 1.0
	charge_speed_multiplier = 1.0
	xp_multiplier = 2.0
	room_reset()
	
	match selected_character:
		"WITCH":
			charge_speed_base = 0.5
			ricochets_base = 2
		_:
			charge_speed_base = 1.0
			ricochets_base = 0

func room_reset():
	ball_power_max = 1.0
	ball_power = 0.0
	xp_multiplier = xp_multiplier * 0.9
	

func charge_ball_power(amount: float) -> void:
	ball_power = clampf(ball_power + amount, 0.0, ball_power_max)

func decay_ball_power(amount: float = 1.0 - ball_power_retention) -> void:
	ball_power = clampf(ball_power - amount, 0.0, ball_power_max)

func add_xp(amount: float) -> void:
	if ball_power_max == 5.0:
		return
	
	ball_power_max = snappedf(clampf(ball_power_max + amount, 0.0, 5.0), XP_SNAP)

func give_item(item: PickupItem) -> void:
	match item.type:
		PickupItem.Type.WALK_SPEED:
			walk_speed_multiplier += item.stat_value / 100.0
		PickupItem.Type.CHARGE_SPEED:
			charge_speed_multiplier += item.stat_value / 100.0
		PickupItem.Type.MAX_HEALTH:
			max_health += item.stat_value
			health += item.stat_value
		PickupItem.Type.SPIN_SLOWMO:
			spin_slowmo_modifier += item.stat_value / 100.0
		PickupItem.Type.SPEED_RETENTION:
			ball_power_retention += item.stat_value / 100.0
		PickupItem.Type.DAMAGE_BONUS:
			damage_bonus += item.stat_value / 100.0
		PickupItem.Type.XP_BONUS:
			xp_multiplier += item.stat_value / 100.0
		PickupItem.Type.HEAL:
			health = min(health + item.stat_value, max_health)



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
	if event.pressed:
		match event.physical_keycode:
			KEY_F1:
				if not _overlay:
					_overlay = load("res://autoload/globals/globals_overlay.tscn").instantiate()
					get_parent().add_child(_overlay)
				else:
					_overlay.visible = not _overlay.visible
			KEY_F2:
				add_xp(1)
	
