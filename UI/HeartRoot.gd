extends Node3D

const heart_scene = preload("res://UI/heart.tscn")
var hearts := []
var current_placement := Vector3(0, 0, 0)
var heart_index := 0 # the point after which full hearts turn into empty hearts on the number line

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(Globals.health):
		add_heart()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Globals.health < heart_index:
		hurt(heart_index - Globals.health)
	elif Globals.health > heart_index:
		heal(Globals.health - heart_index)
	
	if Globals.max_health > hearts.size():
		for i in range(Globals.max_health - hearts.size()):
			add_heart()

func add_heart():
	var new_heart = heart_scene.instantiate()
	add_child(new_heart)
	new_heart.position = current_placement
	current_placement += Vector3(3, 0, 0)
	if heart_index < hearts.size():
		heal(1)
		new_heart.empty = true
	hearts.append(new_heart)
	heart_index += 1

func hurt(amount):
	for i in range(amount):
		hearts[heart_index - 1].empty = true
		heart_index -= 1

func heal(amount):
	for i in range(amount):
		if heart_index >= hearts.size():
			return
		hearts[heart_index].empty = false
		heart_index += 1
