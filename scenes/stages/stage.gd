extends Node

signal player_exit

var ball

@onready var grid_map: GridMap = $GridMap
@onready var world_border: StaticBody3D = $GridMap/WorldBorder
@onready var top_wall: CollisionShape3D = $GridMap/WorldBorder/TopWall
@onready var player_spawn_point: Marker3D = $GridMap/PlayerSpawnPoint
@onready var next_room_area: Area3D = $GridMap/NextRoomArea

func _ready() -> void:
	next_room_area.body_entered.connect(_on_next_room_area_body_entered)

func spawn_enemies() -> void:
	for c in $Enemies.get_children():
		c.spawn()
	
	Globals.stat_changed.connect(_on_stat_changed)
	
	ball.bounce.connect(_on_ball_bounce)

func _on_stat_changed() -> void:
	pass

func _on_ball_bounce(collision: KinematicCollision3D) -> void:
	if Globals.current_gear < 1:
		return
	
	if collision.get_collider_shape() == top_wall:
		get_tree().call_group("Enemy", "deal_damage", 9999)
		_punch_hole(collision.get_position())
		ball.queue_free()

func _on_next_room_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player_exit.emit()

func _punch_hole(where: Vector3) -> void:
	next_room_area.monitoring = true
	
	var hitTile: Vector3i = grid_map.local_to_map(where)
	hitTile.z = 0
	
	print("_punch_hole(where: %s) -> %s" % [where, hitTile])
	
	grid_map.set_cell_item(hitTile, 0) # Ideally new broken wall tile
	#var hitTile2 = grid_map.local_to_map(body.position + Vector3(.5, 0, 0))
	#hitTile2.z = 0
	#if hitTile == hitTile2:
		#hitTile2 = grid_map.local_to_map(body.position - Vector3(.5, 0, 0))
		#hitTile2.z = 0
		#grid_map.set_cell_item(hitTile - Vector3i(0, 0, 1), 2,
			#grid_map.get_orthogonal_index_from_basis(Basis(Vector3(0, 1, 0), -PI/2)))
		#grid_map.set_cell_item(hitTile2 - Vector3i(0, 0, 1), 2,
			#grid_map.get_orthogonal_index_from_basis(Basis(Vector3(0, 1, 0), PI/2)))
	#else:
		#grid_map.set_cell_item(hitTile - Vector3i(0, 0, 1), 2,
			#grid_map.get_orthogonal_index_from_basis(Basis(Vector3(0, 1, 0), PI/2)))
		#grid_map.set_cell_item(hitTile2 - Vector3i(0, 0, 1), 2,
			#grid_map.get_orthogonal_index_from_basis(Basis(Vector3(0, 1, 0), -PI/2)))
	#grid_map.set_cell_item(hitTile2, 0)
