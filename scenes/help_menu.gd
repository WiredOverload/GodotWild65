extends Node3D

@onready var left: AnimatedSprite3D = $Camera3D/Buttons/Left
@onready var right: AnimatedSprite3D = $Camera3D/Buttons/Right

var _page: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_goto_page(1)


func _goto_page(p: int):
	if _page:
		get_node("Page%s" % _page).visible = false
	_page = p
	get_node("Page%s" % _page).visible = true
	
	left.visible = _page > 1
	right.visible = _page < 4

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("action") or Input.is_physical_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		return
	
	if _page < 4 and Input.is_action_just_pressed("move_right"):
		_goto_page(_page + 1)
	
	if _page > 1 and Input.is_action_just_pressed("move_left"):
		_goto_page(_page - 1)
