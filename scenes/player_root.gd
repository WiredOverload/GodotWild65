extends Node3D

signal entrance_walk_complete

@onready var camera: Camera3D = $Camera
@onready var player = %Player
@onready var ball = $Ball
@onready var cutscene_animation_player: AnimationPlayer = $CutsceneAnimationPlayer

func play_entrance_cutscene() -> void:
	player.get_node("PlayerModelTeacher/MotionInterpolator3D").enabled = false
	cutscene_animation_player.play("RoomEntrance")
	cutscene_animation_player.advance(0.0)
	await get_tree().process_frame
	player.get_node("PlayerModelTeacher/MotionInterpolator3D").teleport()
	await cutscene_animation_player.animation_finished
	player.get_node("PlayerModelTeacher/MotionInterpolator3D").enabled = true
