extends Node

const TEST_CAMERA_3D = "res://autoload/test_camera_3d/test_camera_3d.tscn"

func _ready():
	await get_tree().process_frame
	
	if get_viewport().get_camera_3d() != null:
		return
	
	var visual_instances := get_tree().root.find_children("*", "VisualInstance3D", true, false)
	
	if visual_instances.is_empty():
		return
	
	await get_tree().process_frame
	
	get_tree().root.add_child(load(TEST_CAMERA_3D).instantiate())
	
