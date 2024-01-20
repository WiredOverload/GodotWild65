extends StaticBody3D

@onready var bookshelf_anim: AnimationPlayer = $BookshelfModel/AnimationPlayer

func _ready() -> void:
	bookshelf_anim.play("Spawn")
	bookshelf_anim.advance(0.0)
