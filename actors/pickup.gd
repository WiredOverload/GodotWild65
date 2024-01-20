extends Node3D

signal taken

@export var item: PickupItem

@onready var gimbal: Node3D = %Gimbal
@onready var core_mesh: MeshInstance3D = %CoreMesh
@onready var inner_spikes_mesh: MeshInstance3D = %InnerSpikesMesh
@onready var outer_spikes_mesh: MeshInstance3D = %OuterSpikesMesh
@onready var label: Label3D = %Label
@onready var button_sprite: AnimatedSprite3D = %ButtonSprite

var _player


func _ready() -> void:
	#assert(item)
	if not item:
		return
	
	var color := item.display_color()
	
	outer_spikes_mesh.set_instance_shader_parameter(&"albedo_color", color)
	inner_spikes_mesh.set_instance_shader_parameter(&"albedo_color", color.lerp(Color.WHITE, 0.5))
	core_mesh.material_override.albedo_color = color.lerp(Color.WHITE, 0.9)
	



func _on_detector_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		button_sprite.visible = true
		body.action_pressed.connect(_on_player_action_pressed)
		_player = body


func _on_detector_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		button_sprite.visible = false
		body.action_pressed.disconnect(_on_player_action_pressed)
		_player = null

func _on_player_action_pressed() -> void:
	assert(_player)
	Globals.give_item(item)
	taken.emit()
	queue_free()
