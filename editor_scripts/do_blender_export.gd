@tool
extends EditorScript

# Not done yet. Probably never will be.

func _run() -> void:
	assert(false)
	
	var source_global := ProjectSettings.globalize_path("res://character_models/book.blend")
	var destination_global := ProjectSettings.globalize_path("res://character_models/gltf/book.glb")
	
	var blender_major_version := 3
	var blender_minor_version := 6
	
	var request_options := {}
	var parameters_map := {}
	
	parameters_map["filepath"] = destination_global
	parameters_map["export_keep_originals"] = true
	parameters_map["export_format"] = "GLTF_SEPARATE"
	parameters_map["export_yup"] = true
	parameters_map["export_extras"] = true
	parameters_map["export_skins"] = true
	parameters_map["export_all_influences"] = true
	parameters_map["export_materials"] = "EXPORT"
	parameters_map["export_cameras"] = false
	parameters_map["export_lights"] = true
	parameters_map["export_colors"] = true
	parameters_map["use_visible"] = true
	parameters_map["export_texcoords"] = true
	parameters_map["export_normals"] = true
	parameters_map["export_tangents"] = true
	
	if blender_major_version > 3 or (blender_major_version == 3 and blender_minor_version >= 6):
		parameters_map["export_animation_mode"] = "ACTIONS"
	else:
		parameters_map["export_nla_strips"] = true

	parameters_map["export_frame_range"] = true
	parameters_map["export_force_sampling"] = true
	parameters_map["export_def_bones"] = false
	parameters_map["export_apply"] = true
	
	request_options["unpack_all"] = true
	request_options["path"] = source_global
	request_options["gltf_options"] = parameters_map
