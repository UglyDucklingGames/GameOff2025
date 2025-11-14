class_name PlayerController extends CharacterBody3D

#Constants
const MOUSE_SENS:float = 0.25
const VLOOK_BOUNDS:float = 89.9 # vertical look bounds

const BASE_SPEED:float = 5.0 # default movement speed m/s.
const ACCEL_WATER:float = 5.0
const ACCEL_LAND:float = 10.0

const GRAVITY_WATER:float = -0.5 # was -1.0
const JUMP_FORCE:float = 5.0

const HEIGHT:float = 1.75

const LUNG_OXYGEN_MAX:float = 5.0
const BASE_OXYGEN:float = 20.0
const OXYGEN_REPLENISH_RATE:float = 5.0

# Object references
@onready var neck_h: Node3D = %NeckH
@onready var neck_v: Node3D = %NeckV
@onready var camera: Camera3D = %Camera
@onready var water_overlay: ColorRect = %WaterOverlay
@onready var suffocation_overlay: ColorRect = %SuffocationOverlay
@onready var depth_guage: Label = %DepthGuage
@onready var interact_ray: RayCast3D = %InteractRay
@onready var interact_text: Label = %InteractText

var debug_mode:bool = false

var in_water:bool = true
var head_in_water:bool = true
var speed:float = BASE_SPEED

var depth:float

var oxygen_capacity:float = BASE_OXYGEN
var oxygen:float = oxygen_capacity
var lung_oxygen:float = LUNG_OXYGEN_MAX # last resort before death


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # capture mouse when player is active
	
	debug_mode = OS.has_feature("debug")


func _physics_process(delta: float) -> void:
	_process_input()
	
	_calculate_in_water()
	_process_oxygen(delta)
	
	if in_water:
		_move_water(delta)
	else:
		_move_land(delta)
	
	# Depth guage
	depth = Water.get_depth(global_position.y)
	depth_guage.text = "Depth: " + "%.1f" % depth + "m"
	depth_guage.text += "\nMoney: " + str(PlayerData.get_money())
	depth_guage.text += "\nO2: " + "%.1f" % oxygen + "s"
	
	_process_interaction()


## Handle all mouse interaction.
func _process_interaction() -> void:
	if interact_ray.is_colliding() and interact_ray.get_collider() is InteractZone:
		# Display text
		var interact_zone:InteractZone = interact_ray.get_collider() as InteractZone
		interact_text.text = interact_zone.get_string()
		
		# Interaction
		if Input.is_action_just_pressed(&"interact"):
			interact_zone.interact()
	else:
		interact_text.text = ""


## Handle all water/land determination logic.
func _calculate_in_water() -> void:
	var old_in_water:bool = in_water
	# TODO use depth value for this instead
	in_water = global_position.y <= Water.WATER_HEIGHT - (HEIGHT*0.25)
	
	# When entering or exiting water
	if old_in_water != in_water:
		# When leaving water
		if !in_water and velocity.y > 0:
			velocity.y = JUMP_FORCE*0.5
		
		var underwater_objects:Node3D = get_tree().get_first_node_in_group(&"underwater")
		underwater_objects.visible = in_water
	
	# Visuals
	head_in_water = camera.global_position.y <= Water.WATER_HEIGHT
	water_overlay.visible = head_in_water


## Handle oxygen levels and drowning.
func _process_oxygen(delta: float) -> void:
	if head_in_water:
		# Drain oxygen (1 point per second)
		oxygen = move_toward(oxygen, 0, delta)
		
		# Drain oxygen in lungs if out of tank oxygen
		if oxygen <= 0.0:
			lung_oxygen = move_toward(lung_oxygen, 0, delta)
			
			# Fade in blackness until dead
			suffocation_overlay.show()
			suffocation_overlay.color.a = 1.0 - (lung_oxygen / LUNG_OXYGEN_MAX)
			
			# Kill if out of lung oxygen
			if lung_oxygen <= 0.0:
				get_tree().quit() # you died
	else:
		# Replenish oxygen (OXYGEN_REPLENISH_RATE points per second)
		oxygen = move_toward(oxygen, oxygen_capacity, OXYGEN_REPLENISH_RATE*delta)
		lung_oxygen = LUNG_OXYGEN_MAX # instantly replenish lung oxygen
		suffocation_overlay.hide() # hide suffocation overlay


## Get WASD horizontal movement vector.
func get_input_dir() -> Vector2:
	return Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_backward")


## Handle player movement.
func _move_water(delta: float) -> void:
	var input_dir:Vector2 = get_input_dir() # WASD movement
	
	# Q and E relative y movement 
	# + Space and Control absolute y movement
	var relative_y_input:float
	var y_input:float
	relative_y_input = Input.get_axis(&"move_down_relative", &"move_up_relative")
	y_input = Input.get_axis(&"move_down", &"move_up")
	
	# Get final movement direction
	var dir:Vector3 = neck_v.global_basis * Vector3(input_dir.x, relative_y_input, input_dir.y)
	if y_input: dir.y = y_input # override y if there is y input
	
	dir = dir.normalized() # normalise direction vector
	
	# Gravity
	var current_gravity:float
	if !is_on_floor():
		current_gravity = GRAVITY_WATER
	else:
		current_gravity = 0.0
	
	# Acceleration
	velocity = velocity.lerp((dir*speed) + Vector3(0,current_gravity,0), ACCEL_WATER*delta)
	
	move_and_slide()


## Handle player movement.
func _move_land(delta: float) -> void:
	var input_dir:Vector2 = get_input_dir() # WASD movement
	
	# Movement
	var dir:Vector3 = (neck_h.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Gravity and jumping
	if !is_on_floor():
		velocity.y += get_gravity().y * delta # add gravity
	else:
		if Input.is_action_just_pressed(&"move_up"):
			velocity.y = JUMP_FORCE
	
	# Acceleration
	velocity.x = lerpf(velocity.x, dir.x*speed, ACCEL_LAND*delta)
	velocity.z = lerpf(velocity.z, dir.z*speed, ACCEL_LAND*delta)
	
	move_and_slide()


## Handle all non-movement input.
func _process_input() -> void:
	# Debug only
	if !debug_mode: return
	
	# Quit game TODO remove this
	if Input.is_action_just_pressed(&"ui_cancel"):
		get_tree().quit()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Mouselook
		var mouse_motion:InputEventMouseMotion = event as InputEventMouseMotion # get mouse motion
		neck_h.rotation_degrees.y -= mouse_motion.relative.x * MOUSE_SENS
		neck_v.rotation_degrees.x -= mouse_motion.relative.y * MOUSE_SENS
		neck_v.rotation_degrees.x = clamp(neck_v.rotation_degrees.x, -VLOOK_BOUNDS, VLOOK_BOUNDS)
