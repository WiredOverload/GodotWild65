class_name GenericSignaller
extends Node3D

signal event(what: StringName)

func emit(what: StringName) -> void:
	event.emit(what)
	
