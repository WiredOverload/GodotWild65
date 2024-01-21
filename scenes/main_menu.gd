extends Node3D

enum {
	OPTION_NONE,
	OPTION_START,
	OPTION_HELP,
}

@onready var camera_pivot: Node3D = $CameraPivot
@onready var start_label: Label3D = %StartLabel
@onready var help_label: Label3D = %HelpLabel

var _time: float

var _selected := OPTION_NONE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicMan.play_menu()
	_select(OPTION_START)


func _select(o: int) -> void:
	match _selected:
		OPTION_NONE:
			pass
		OPTION_START:
			start_label.text = "start game"
		OPTION_HELP:
			help_label.text = "help"
	
	_selected = o
	
	match _selected:
		OPTION_NONE:
			assert(false)
		OPTION_START:
			start_label.text = "> start game <"
		OPTION_HELP:
			help_label.text = "> help <"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_time += delta
	camera_pivot.rotation.y = (1.0 + cos(_time / 3.0)) * TAU / 8.0
	
	if Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("move_down"):
		match _selected:
			OPTION_NONE:
				assert(false)
			OPTION_START:
				_select(OPTION_HELP)
			OPTION_HELP:
				_select(OPTION_START)
		# TODO: sfx bwop
	
	if Input.is_action_just_pressed("action"):
		match _selected:
			OPTION_NONE:
				assert(false)
			OPTION_START:
				_start_game()
			OPTION_HELP:
				_help()
	

func _start_game():
	get_tree().change_scene_to_file("res://scenes/character_select.tscn")


func _help():
	get_tree().change_scene_to_file("res://scenes/help_menu.tscn")
