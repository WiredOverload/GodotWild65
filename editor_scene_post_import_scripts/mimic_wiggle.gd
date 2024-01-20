@tool
extends EditorScenePostImport

# Called by the editor when a scene has this script set as the import script in the import tab.
func _post_import(scene: Node) -> Object:
	
	var wiggle_properties_dir := get_source_file().get_base_dir().path_join("wiggle_properties")
	
	var name := get_source_file().get_file()
	name = name.substr(0, name.find("."))
	
	print("mimic_wiggle scene post-import script:")
	print("    Processing ", get_source_file())
	print("    wiggle_properties_dir: ", wiggle_properties_dir)
	
	var skeletons = scene.find_children("*", "Skeleton3D")
	
	for skeleton: Skeleton3D in skeletons:
		print("    Found skeleton: ", skeleton.name)
		for i: int in range(skeleton.get_bone_count()):
			var bone_name := skeleton.get_bone_name(i)
			if bone_name.contains("Wiggle"):
				print("    Found wiggle bone: ", bone_name)
				
				_ensure_exists(wiggle_properties_dir)
				
				var wiggle_properties_filename := "%s_%s_properties.tres" % [name, bone_name]
				var wiggle_properties_path := wiggle_properties_dir.path_join(wiggle_properties_filename)
				
				var wiggle_bone := WiggleBone.new()
				wiggle_bone.name = "WiggleBone_%s" % [bone_name]
				wiggle_bone.bone_name = bone_name
				wiggle_bone.bone_idx = i
				
				if FileAccess.file_exists(wiggle_properties_path):
					print("    Loading existing WiggleProperties: ", wiggle_properties_path)
					wiggle_bone.properties = load(wiggle_properties_path)
				else:
					print("    Creating new WiggleProperties: ", wiggle_properties_path)
					var properties: WiggleProperties = load("res://editor_scene_post_import_scripts/mimic_wiggle_default_properties.tres").duplicate()
					ResourceSaver.save(properties, wiggle_properties_path, ResourceSaver.FLAG_CHANGE_PATH)
					wiggle_bone.properties = properties
				
				skeleton.add_child(wiggle_bone)
				wiggle_bone.set_owner(scene)
				print("    Added bone to skeleton.")
	
	return scene


func _ensure_exists(dir: String) -> void:
	var global_dir := ProjectSettings.globalize_path(dir)
	if not DirAccess.dir_exists_absolute(global_dir):
		print("    Creating dir: ", dir)
		DirAccess.make_dir_recursive_absolute(global_dir)
