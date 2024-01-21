extends StaticBody3D

enum State {
	SPAWN,
	IDLE,
	ATTACK,
	DEATH,
}

var state: State = State.SPAWN: set = set_state

@onready var locker_model: GenericSignaller = $LockerModel

@onready var trunk_model = $LockerModel
@onready var trunk_anim: AnimationPlayer = trunk_model.get_node("AnimationPlayer")
@onready var action_timer: Timer = $ActionTimer
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	# spawn
	trunk_anim.play("Spawn")
	trunk_anim.advance(0.0)
	await trunk_anim.animation_finished
	state = State.IDLE

func set_state(v: State) -> void:
	
	state = v
	
	match state:
		State.DEATH:
			collision_shape_3d.disabled = true
			action_timer.stop()

func kill(room_clear: bool = false) -> void:
	if state == State.DEATH:
		return
	state = State.DEATH
	
	# fade to alpha zero and color to red
	var mesh_instance: MeshInstance3D = trunk_model.get_node("TrunkArmature/Skeleton3D/Trunk")
	var material: BaseMaterial3D = mesh_instance.mesh["surface_0/material"].duplicate()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_instance["surface_material_override/0"] = material
	var tween := create_tween()
	tween.tween_interval(0.5)
	tween.tween_property(material, "albedo_color", Color(1, 0, 0, 0), 0.5)
	
	# despawn
	trunk_anim.play_backwards("Spawn")
	await trunk_anim.animation_finished
	
	queue_free()


func _on_action_timer_timeout() -> void:
	if state != State.IDLE:
		action_timer.start()
		return
	
	state = State.ATTACK
	
	trunk_anim.play("Attack")
	trunk_anim.advance(0.0)
	await trunk_anim.animation_finished
	if state != State.ATTACK:
		return
	
	# TODO
	
	action_timer.start()
	state = State.IDLE

