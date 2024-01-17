extends Node

var health := 3
var max_health := 5
var gear := 0
var difficulty := 0

func room_reset():
	gear = 0

func reset():
	health = 3
	max_health = 5
	gear = 0
	difficulty = 0
