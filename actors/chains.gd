extends Node3D

signal unlocked

@export_range(1, 5) var level: int = 1

@onready var chains: MeshInstance3D = $Chains
@onready var barrier: MeshInstance3D = $Barrier


@onready var locks: Array[Node3D] = [
	$Lock1,
	$Lock2,
	$Lock3,
	$Lock4,
	$Lock5,
]

@onready var lock_breaks: Array[GPUParticles3D] = [
	$LockBreak1,
	$LockBreak2,
	$LockBreak3,
	$LockBreak4,
	$LockBreak5,
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Chain spawned with level = ", level)
	Globals.stat_changed.connect(_on_global_stat_changed)
	for i: int in range(1, 6):
		if level < i:
			locks[i - 1].visible = false
	_on_global_stat_changed()


func _on_global_stat_changed() -> void:
	for i: int in range(1, level + 1):
		var unlocked := Globals.current_max_gear >= i
		if unlocked and locks[level - i].visible:
			locks[level - i].visible = false
			lock_breaks[level - i].emitting = true
			# TODO: sfx Destruction_Metal_Pole_L_Wave_2_0_0.wav
	if Globals.current_max_gear >= level:
		create_tween().tween_property(chains, "transparency", 1.0, 0.5)
		$TargetIndicator.visible = true
		unlocked.emit()
