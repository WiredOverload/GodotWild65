class_name EnemyStatus
extends Node

signal stats_changed

@export_range(1, 50) var max_health: int = 5: set = set_max_health
@export_range(1, 5) var required_gear_level: int = 1: set = set_required_gear_level
@export_range(0.0, 1.0, 0.01) var xp_value: float = 0.1: set = set_xp_value

var current_health: int: set = set_current_health

func _ready() -> void:
	current_health = max_health


func set_current_health(v: int) -> void:
	if v < current_health:
		print_rich("[shake][color=red]Enemy damaged:[/color][/shake] %s took [color=red]%s[/color] damage ([color=red]%s[/color]/[color=red]%s[/color] remaining HP)." % [get_parent().name, current_health - v, v, max_health])
	elif v > current_health:
		print_rich("[color=cyan]Enemy healed:[/color] %s was healed for [color=cyan]%s[/color] HP ([color=red]%s[/color]/[color=red]%s[/color] remaining HP)." % [get_parent().name, v - current_health, v, max_health])
	current_health = clamp(v, 0, max_health)
	stats_changed.emit()
	if current_health == 0:
		Globals.add_xp(xp_value * Globals.xp_multiplier)
		get_parent().kill()

func set_max_health(v: int) -> void:
	max_health = v
	if max_health < current_health:
		current_health = max_health
	stats_changed.emit()

func set_required_gear_level(v: int) -> void:
	required_gear_level = v
	stats_changed.emit()

func set_xp_value(v: float) -> void:
	xp_value = v
	stats_changed.emit()


