extends Node3D

var sprite_finished := false
var audio_finished := false


func _on_animated_sprite_3d_animation_finished() -> void:
	sprite_finished = true
	if audio_finished:
		queue_free()


func _on_audio_stream_player_finished() -> void:
	audio_finished = true
	if sprite_finished:
		queue_free()
