extends Node

const PICKUP_SCENE: PackedScene = preload("res://actors/pickup.tscn")

signal player_exit

var ball

@onready var grid_map: GridMap = $GridMap
@onready var world_border: StaticBody3D = $GridMap/WorldBorder
@onready var top_wall: CollisionShape3D = $GridMap/WorldBorder/TopWall
@onready var player_spawn_point: Marker3D = $GridMap/PlayerSpawnPoint
@onready var next_room_area: Area3D = $GridMap/NextRoomArea
@onready var go_arrow: Node3D = $GridMap/GoArrow
@onready var spikes: Node3D = $GridMap/Spikes

@onready var reward_spawns: Array[Node3D] = [
	$GridMap/RewardPoint1,
	$GridMap/RewardPoint2,
]

@onready var possible_rewards: Array[PickupItem] = [
	preload("res://reward_items/walk_speed_1.tres"),
	preload("res://reward_items/charge_speed_1.tres"),
]


var _rewards: Array[Node3D] = []

func _ready() -> void:
	next_room_area.body_entered.connect(_on_next_room_area_body_entered)

func spawn_enemies() -> void:
	for c in $Enemies.get_children():
		c.spawn()
	
	Globals.stat_changed.connect(_on_stat_changed)
	
	ball.bounce.connect(_on_ball_bounce)

func close_entrance() -> void:
	spikes.visible = true

func _on_stat_changed() -> void:
	pass

func _on_ball_bounce(collision: KinematicCollision3D) -> void:
	if Globals.current_gear < 1:
		return
	
	if collision.get_collider_shape() == top_wall:
		get_tree().call_group("Enemy", "deal_damage", 9999)
		_punch_hole(collision.get_position())
		_spawn_rewards()
		ball.queue_free()

func _on_next_room_area_body_entered(body: Node3D) -> void:
	if _rewards.is_empty() and body.is_in_group("Player"):
		player_exit.emit()

func _punch_hole(where: Vector3) -> void:
	next_room_area.monitoring = true
	
	var hitTile: Vector3i = grid_map.local_to_map(where)
	hitTile.z = 0
	hitTile.x = clampi(hitTile.x, 1, 22)
	
	print("_punch_hole(where: %s) -> %s" % [where, hitTile])
	
	var clockwise = grid_map.get_orthogonal_index_from_basis(Basis.from_euler(Vector3(0, -TAU / 4.0, 0)))
	var counter_clockwise = grid_map.get_orthogonal_index_from_basis(Basis.from_euler(Vector3(0, TAU / 4.0, 0)))
	
	var floor = grid_map.mesh_library.find_item_by_name("Floor")
	var wall_side = grid_map.mesh_library.find_item_by_name("WallSide")
	
	if hitTile.x == 1:
		grid_map.set_cell_item(hitTile + Vector3i.LEFT, wall_side, counter_clockwise)
	else:
		grid_map.set_cell_item(hitTile + Vector3i.LEFT, floor)
	
	grid_map.set_cell_item(hitTile, floor)
	
	if hitTile.x == 22:
		grid_map.set_cell_item(hitTile + Vector3i.RIGHT, wall_side, clockwise)
	else:
		grid_map.set_cell_item(hitTile + Vector3i.RIGHT, floor)
	
	var tunnel_left = grid_map.mesh_library.find_item_by_name("TunnelLeft")
	var tunnel_center = grid_map.mesh_library.find_item_by_name("TunnelCenter")
	var tunnel_right = grid_map.mesh_library.find_item_by_name("TunnelRight")
	grid_map.set_cell_item(hitTile + Vector3i.FORWARD + Vector3i.LEFT, tunnel_left)
	grid_map.set_cell_item(hitTile + Vector3i.FORWARD, tunnel_center)
	grid_map.set_cell_item(hitTile + Vector3i.FORWARD + Vector3i.RIGHT, tunnel_right)
	
	
	var pos := grid_map.map_to_local(hitTile)
	
	go_arrow.position = Vector3(pos.x, go_arrow.position.y, pos.z)

func _spawn_rewards() -> void:
	for p in reward_spawns:
		var pickup = PICKUP_SCENE.instantiate()
		pickup.position = p.global_position
		pickup.item = possible_rewards.pick_random()
		pickup.taken.connect(_on_reward_taken)
		add_child(pickup)
		_rewards.append(pickup)

func _on_reward_taken():
	for r in _rewards:
		r.queue_free()
	_rewards.clear()
	
	go_arrow.visible = true
