extends Node

var health := 3
var max_health := 5
var difficulty := 0

var bag_raw_speed := 0
var gear: int:
	get: return floori(bag_raw_speed / 10)

func room_reset():
	bag_raw_speed = 0

func reset():
	health = 3
	max_health = 5
	difficulty = 0
