## Collider used for interaction.
class_name InteractZone extends Area3D

## Emitted when this InteractZone is interacted with.
signal interacted

var _interact_string:String = "example text" # hover text


func _init() -> void:
	collision_layer = 1<<2 # interactable layer
	collision_mask = 0 # don't collide with anything
	monitorable = true # can be checked by other colliders
	monitoring = false # don't check for collisions

## Set interact text.
func set_string(s:String) -> void:
	_interact_string = s

## Get interact text.
func get_string() -> String:
	return _interact_string

## Activate this object.
func interact() -> void:
	interacted.emit()
