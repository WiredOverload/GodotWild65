@tool
class_name EnemySpawner
extends Marker3D

enum EnemyType {
	OBELISK,
	BOOK,
	BOOKSHELF,
}

var ENEMY_SCENES := [
	preload("res://actors/enemy.tscn"),
	preload("res://actors/enemy_book.tscn"),
	preload("res://actors/enemy_bookshelf.tscn"),
]

const PREVIEW_MESHES := [
	null,
	"res://character_models/meshes/book_BookMesh.res",
	"res://character_models/meshes/bookshelf_BookshelfMesh.res",
]

const DEFAULT_PREVIEW_MESH := "res://character_models/DO_NOT_SHIP/meshes/enemy_preview_EnemyPreviewMesh.res"

@export var enemy_type: EnemyType = EnemyType.OBELISK: set = set_enemy_type
@export var min_difficulty: int = 0
@export_range(0.01, 1.0, 0.01) var spawn_chance: float = 1.0

@export var spawn_on_ready: bool = false

var _preview_mesh_instance: MeshInstance3D

func _ready() -> void:
	if Engine.is_editor_hint():
		gizmo_extents = 1.0
		_update_preview_mesh()
		return
	
	assert(enemy_type in EnemyType.values())
	assert(min_difficulty >= 0)
	assert(spawn_chance > 0.0)
	assert(spawn_chance <= 1.0)
	
	if spawn_on_ready:
		spawn.call_deferred()

func spawn() -> void:
	queue_free()
	
	if Globals.difficulty < min_difficulty:
		return
	
	if randf() > spawn_chance:
		return
	
	var enemy: Node3D = ENEMY_SCENES[enemy_type].instantiate()
	enemy.transform = transform
	get_parent().add_child(enemy)

func set_enemy_type(v: EnemyType) -> void:
	enemy_type = v
	
	if Engine.is_editor_hint():
		_update_preview_mesh()

func _update_preview_mesh() -> void:
	assert(Engine.is_editor_hint())
	
	if not _preview_mesh_instance:
		_preview_mesh_instance = MeshInstance3D.new()
		add_child(_preview_mesh_instance)
	
	if PREVIEW_MESHES[enemy_type]:
		_preview_mesh_instance.mesh = load(PREVIEW_MESHES[enemy_type])
	else:
		_preview_mesh_instance.mesh = load(DEFAULT_PREVIEW_MESH)
