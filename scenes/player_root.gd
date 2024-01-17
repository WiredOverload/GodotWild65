extends Node3D

@onready var camera: Camera3D = $Camera
@onready var player = %Player
@onready var ball: Ball = $Ball
@onready var cutscene_animation_player: AnimationPlayer = $CutsceneAnimationPlayer

func play_entrance_cutscene() -> Signal:
	cutscene_animation_player.play("RoomEntrance")
	return cutscene_animation_player.animation_finished
