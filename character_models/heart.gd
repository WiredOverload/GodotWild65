extends Node3D

#@onready var camera = get_parent()
@onready var mesh = $Cube
var time = 0
var empty : bool = false:
	set(value):
		empty = value
		if value:
			mesh.mesh.surface_get_material(0).albedo_color = Color.BLACK
		else:
			mesh.mesh.surface_get_material(0).albedo_color = Color("ff53ff")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#look_at(camera.position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	rotate(Vector3.MODEL_TOP, sin(time * 2) * .005)
