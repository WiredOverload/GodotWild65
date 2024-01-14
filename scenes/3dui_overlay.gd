extends SubViewportContainer

@onready var sub_viewport: SubViewport = $SubViewport

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sub_viewport.size = get_viewport().size
