extends Node3D

@onready var mat : ShaderMaterial
var time := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mat = $ShaderMesh.mesh.surface_get_material(0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	mat.set_shader_parameter("size", time)


func _on_timer_timeout() -> void:
	queue_free()
