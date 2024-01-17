extends Node

@onready var grid_map: GridMap = $GridMap
@onready var world_border: StaticBody3D = $WorldBorder
@onready var top_wall: CollisionShape3D = $WorldBorder/TopWall
