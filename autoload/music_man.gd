extends Node


@onready var menu_bgm: AudioStreamPlayer = $MenuBGM
@onready var dungeon_bgm: AudioStreamPlayer = $DungeonBGM

func play_dungeon():
	if dungeon_bgm.playing:
		return
	menu_bgm.stop()
	dungeon_bgm.play()

func play_menu():
	if menu_bgm.playing:
		return
	dungeon_bgm.stop()
	menu_bgm.play()
