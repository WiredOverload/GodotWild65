extends Node

@onready var grid_map: GridMap = $GridMap
@onready var world_border: StaticBody3D = $WorldBorder
@onready var top_wall: CollisionShape3D = $WorldBorder/TopWall
@onready var player_spawn_point: Marker3D = $PlayerSpawnPoint

func spawn_enemies() -> void:
	for c in $Enemies.get_children():
		c.spawn()
