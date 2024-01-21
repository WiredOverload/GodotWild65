extends Node3D

@onready var press_me: AnimatedSprite3D = $Camera3D/Buttons/PressMe

func _process(delta: float) -> void:
	if Input.is_physical_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	
	if not press_me.visible:
		return
	
	if Input.is_action_just_pressed("action"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_timer_timeout() -> void:
	press_me.visible = true
