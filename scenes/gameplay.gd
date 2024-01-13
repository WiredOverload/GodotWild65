class_name Gameplay
extends Node3D

static var instance: Gameplay


var time_scale: float = 1.0


func _enter_tree() -> void:
	assert(instance == null)
	instance = self

func _exit_tree() -> void:
	assert(instance == self)
	instance = null

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
