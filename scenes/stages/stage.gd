extends Node

@onready var grid_map: GridMap = $GridMap
@onready var world_border: StaticBody3D = $WorldBorder
#@onready var top_wall: CollisionShape3D = $WorldBorder/TopWall
@onready var player_spawn_point: Marker3D = $PlayerSpawnPoint
@onready var next_room_area: Area3D = $WorldBorder/NextRoomArea

func spawn_enemies() -> void:
	for c in $Enemies.get_children():
		c.spawn()

func _process(delta: float) -> void:
	if Globals.current_gear >= 1:
		next_room_area.monitoring = false
	else:
		next_room_area.monitoring = true


func _on_next_room_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Ball"):
		get_tree().call_group("Enemy", "hit", 100)
		var hitTile : Vector3i = grid_map.local_to_map(body.position)
		hitTile.z = 0
		print(hitTile)
		grid_map.set_cell_item(hitTile, 0) # Ideally new broken wall tile
		var hitTile2 = grid_map.local_to_map(body.position + Vector3(.5, 0, 0))
		hitTile2.z = 0
		if hitTile == hitTile2:
			hitTile2 = grid_map.local_to_map(body.position - Vector3(.5, 0, 0))
			hitTile2.z = 0
			grid_map.set_cell_item(hitTile - Vector3i(0, 0, 1), 2,
				grid_map.get_orthogonal_index_from_basis(Basis(Vector3(0, 1, 0), -PI/2)))
			grid_map.set_cell_item(hitTile2 - Vector3i(0, 0, 1), 2,
				grid_map.get_orthogonal_index_from_basis(Basis(Vector3(0, 1, 0), PI/2)))
		else:
			grid_map.set_cell_item(hitTile - Vector3i(0, 0, 1), 2,
				grid_map.get_orthogonal_index_from_basis(Basis(Vector3(0, 1, 0), PI/2)))
			grid_map.set_cell_item(hitTile2 - Vector3i(0, 0, 1), 2,
				grid_map.get_orthogonal_index_from_basis(Basis(Vector3(0, 1, 0), -PI/2)))
		grid_map.set_cell_item(hitTile2, 0)
		body.queue_free()
	elif body.is_in_group("Player"):
		next_room()

func next_room():
	Globals.room_reset()
	Globals.difficulty += 1
	#_player_root.position = Vector3(15, 0, 12)
	#
	#var ball_spawn = ball.instantiate()
	#add_child(ball_spawn)
	#ball_spawn.position = Vector3(randf_range(1, 23), 0, randf_range(1, 13))
