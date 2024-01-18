extends Node3D

@onready var mesh = $Cube
var full_material := preload("res://materials/heart_full.tres")
var empty_material := preload("res://materials/heart_empty.tres")
var time = 0
var empty : bool = false:
	set(value):
		empty = value
		if value == true:
			mesh.mesh.surface_set_material(0, empty_material)
		else:
			mesh.mesh.surface_set_material(0, full_material)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	rotate(Vector3.MODEL_TOP, sin(time * 2) * .005)
