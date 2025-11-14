extends Node3D

@onready var interact_zone: InteractZone = $InteractZone
@onready var mesh: MeshInstance3D = $Mesh

# Treasure data
static var data:Dictionary = JSONParser.parse("res://data/treasure.json")
var _treasure_type:Dictionary
# Variables for easy access
var _tier:String
var _value:int = 0
var _colour:String

func _ready() -> void:
	await get_tree().process_frame
	
	var depth:float = Water.get_depth(global_position.y)
	_treasure_type = get_treasure_type(depth) # choose a treasure type
	
	# Set string if valid treasure type
	if _treasure_type:
		# Assign data to variables
		_tier = _treasure_type["tier"]
		_value = _treasure_type["value"]
		_colour = _treasure_type["col"]
		# Set interact hovering string
		interact_zone.set_string(_to_string())
		
		# Set treasure colour
		var c:Color = Color(_colour)
		mesh.set_instance_shader_parameter("colour", Vector3(c.r, c.g, c.b))
	else:
		# Invalid treasure type
		queue_free()
		push_error("Treasure '" + name + "' has no type")


## Randomly select treasure type and return [code]Dictionary[/code] with treasure information.
static func get_treasure_type(depth:float) -> Dictionary:
	var elements:Array = data["treasure"]
	
	# Pick random and cycle until a valid element is found
	var index:int = randi() % elements.size()
	var current:Dictionary = elements[index]
	var loop_count:int = 0 # loop counter for safety
	var dir:int = 1 -(randi()%2)*2 # direction to increment (1 or -1)
	
	# Find type that is at correct depth
	while depth > current["depthmax"] or depth < current["depthmin"]:
		index = (index+dir)%elements.size() # increment index and wrap around
		current = elements[index] # try element at new index
		
		# Stop loop and return nothing if no valid type was found
		loop_count += 1
		if loop_count > elements.size()-1:
			return {} # return empty dictionary
	
	return current # return dictionary if valid type was found


## Convert treasure type to [code]String[/code].
func _to_string() -> String:
	var s:String = ""
	s += _tier + " Anomaly" # name
	s += " - $" + str(_value) # price
	
	return s # return string

func _on_interact_zone_interacted() -> void:
	# Pick up treasure when interacted
	PlayerData.add_money(_value)
	queue_free()
