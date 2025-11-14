@tool
class_name Water extends Node3D

const WATER_HEIGHT:float = -10.0
@onready var water_mesh: MeshInstance3D = $WaterMesh

func _ready() -> void:
	water_mesh.global_position.y = WATER_HEIGHT # set water to correct height

## Get depth value at specified y position.
static func get_depth(y_position:float) -> float:
	return max((y_position - WATER_HEIGHT) * -1, 0)
