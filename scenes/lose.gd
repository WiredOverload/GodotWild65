extends Node3D


func _on_button_pressed() -> void:
	Globals.reset()
	get_tree().change_scene_to_file("res://scenes/gameplay.tscn")
