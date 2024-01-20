extends Node3D


func _ready() -> void:
	set_process(false)

func activate() -> void:
	set_process(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass # TODO: spin and stuff
