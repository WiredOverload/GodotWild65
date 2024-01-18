extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.stat_changed.connect(_on_stat_changed)
	_on_stat_changed()


func _on_stat_changed() -> void:
	text = str(Globals.current_gear)
