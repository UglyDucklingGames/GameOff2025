class_name Water extends Node3D

const WATER_HEIGHT:float = 0.0
@onready var water_mesh: MeshInstance3D = $WaterMesh

func _ready() -> void:
	water_mesh.global_position.y = WATER_HEIGHT # set water to correct height
