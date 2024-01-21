extends StaticBody3D

@onready var desk_anim: AnimationPlayer = $DeskModel/AnimationPlayer

func _ready() -> void:
	desk_anim.play("Spawn")
	desk_anim.advance(0.0)
