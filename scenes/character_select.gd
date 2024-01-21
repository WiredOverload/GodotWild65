extends Node3D

const GAMEPLAY_SCENE_FILE = "res://scenes/gameplay.tscn"

@onready var teacher: Node3D = $TEACHER


var selected_node: Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selected_node = teacher
	_select("TEACHER")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right"):
		if selected_node.name == "TEACHER":
			_select("WITCH")
		elif selected_node.name == "WITCH":
			_select("TEACHER")
	
	if Input.is_action_just_pressed("action"):
		Globals.selected_character = selected_node.name
		get_tree().change_scene_to_file(GAMEPLAY_SCENE_FILE)
	
	selected_node.get_node("Model").rotation.y += delta

func _select(select_name: String):
	selected_node.get_node("SpotLight3D").visible = false
	selected_node.get_node("Model/AnimationPlayer").play("RESET")
	selected_node.get_node("Model").rotation.y = 0
	
	selected_node = get_node(select_name)
	
	selected_node.get_node("SpotLight3D").visible = true
	selected_node.get_node("Model/AnimationPlayer").play("Walk")

