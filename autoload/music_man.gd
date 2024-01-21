extends Node


@onready var menu_bgm: AudioStreamPlayer = $MenuBGM
@onready var dungeon_bgm: AudioStreamPlayer = $DungeonBGM

func play_dungeon():
	menu_bgm.stop()
	dungeon_bgm.play()

func play_menu():
	dungeon_bgm.stop()
	menu_bgm.play()
