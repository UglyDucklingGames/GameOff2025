## Node that handles random treasure placement.
class_name TreasurePlacer extends Node3D

const MAXIMUM_DEPTH:int = -1000 # lowest depth of treasure spawn
const TREASURE_MIN:int = 35 # minimum number of treasure items
const TREASURE_MAX:int = 50 # maximum number of treasure items
const MAP_SQUARE_RADIUS:int = 100 # half the map size

const TREASURE_SCENE:PackedScene = preload("res://objects/treasure/treasure.tscn")

var ray:RayCast3D # ray to check depth
var used_locations:Array[Vector2] = [] # array of all used locations


func _ready() -> void:
	# Create depth-check raycast
	ray = RayCast3D.new()
	ray.target_position = Vector3(0, MAXIMUM_DEPTH, 0)
	ray.collision_mask = 1 # only collide with world
	ray.enabled = false # only collide when required
	add_child(ray)
	
	global_position.y = Water.WATER_HEIGHT # start from water height
	
	# Place treasure a random number of times
	for _n:int in randi_range(TREASURE_MIN, TREASURE_MAX):
		_find_treasure_spot()
	
	used_locations.clear() # empty array


## Go to a random position within the map bounds.
func _go_to_random() -> void:
	global_position.x = randi_range(-MAP_SQUARE_RADIUS, MAP_SQUARE_RADIUS)
	global_position.z = randi_range(-MAP_SQUARE_RADIUS, MAP_SQUARE_RADIUS)


## Place a single piece of treasure at a random location.
func _find_treasure_spot() -> void:
	# Go to a random position
	_go_to_random()
	ray.force_raycast_update()
	
	# Find a new position until valid
	while !ray.is_colliding() or Vector2(global_position.x, global_position.z) in used_locations:
		ray.force_raycast_update()
		_go_to_random()
	
	# Add treasure at ray hit location
	_place_treasure(ray.get_collision_point())
	
	# Add location to array
	used_locations.append(Vector2(global_position.x, global_position.z))


## Create a treasure object at the specified location.
func _place_treasure(at:Vector3) -> void:
	var treasure:Node3D = TREASURE_SCENE.instantiate()
	treasure.top_level = true
	add_child(treasure)
	treasure.global_position = at
