extends StaticBody3D

enum State {
	SPAWN,
	IDLE,
	WOBBLE_SHOOT,
	DEATH,
}

var state: State = State.SPAWN: set = set_state

@onready var locker_model: GenericSignaller = $LockerModel

@onready var locker = $LockerModel
@onready var locker_anim: AnimationPlayer = locker.get_node("AnimationPlayer")
@onready var action_timer: Timer = $ActionTimer
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	# spawn
	locker_anim.play("Spawn")
	locker_anim.advance(0.0)
	await locker_anim.animation_finished
	state = State.IDLE

func set_state(v: State) -> void:
	
	state = v
	
	match state:
		State.DEATH:
			collision_shape_3d.disabled = true
			action_timer.stop()

func kill() -> void:
	if state == State.DEATH:
		return
	state = State.DEATH
	
	# fade to alpha zero and color to red
	var mesh_instance: MeshInstance3D = locker.get_node("LockerModel/Skeleton3D/Locker")
	var material: BaseMaterial3D = mesh_instance.mesh["surface_0/material"].duplicate()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_instance["surface_material_override/0"] = material
	var tween := create_tween()
	tween.tween_interval(0.5)
	tween.tween_property(material, "albedo_color", Color(1, 0, 0, 0), 0.5)
	
	# despawn
	locker_anim.play_backwards("Spawn")
	await locker_anim.animation_finished
	
	queue_free()


func _on_action_timer_timeout() -> void:
	if state != State.IDLE:
		action_timer.start()
		return
	
	state = State.WOBBLE_SHOOT
	
	locker_anim.play("Wobble")
	locker_anim.advance(0.0)
	await locker_anim.animation_finished
	if state != State.WOBBLE_SHOOT:
		return
	
	await get_tree().create_timer(0.5).timeout
	if state != State.WOBBLE_SHOOT:
		return
	
	locker_anim.play("Open")
	locker_anim.advance(0.0)
	await locker_anim.animation_finished
	if state != State.WOBBLE_SHOOT:
		return
	
	await get_tree().create_timer(0.5).timeout
	if state != State.WOBBLE_SHOOT:
		return
	
	locker_anim.play("Close")
	locker_anim.advance(0.0)
	await locker_anim.animation_finished
	if state != State.WOBBLE_SHOOT:
		return
	
	action_timer.start()
	state = State.IDLE
