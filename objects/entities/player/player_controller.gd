class_name PlayerController extends CharacterBody3D

#Constants
const MOUSE_SENS:float = 0.25
const VLOOK_BOUNDS:float = 89.9 # vertical look bounds

const BASE_SPEED:float = 5.0 # default movement speed m/s.
const ACCEL_WATER:float = 5.0
const ACCEL_LAND:float = 10.0

const GRAVITY_WATER:float = -1.0
const JUMP_FORCE:float = 5.0

# Object references
@onready var neck_h: Node3D = %NeckH
@onready var neck_v: Node3D = %NeckV

var debug_mode:bool = false

var in_water:bool = false
var speed:float = BASE_SPEED


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # capture mouse when player is active
	
	debug_mode = OS.has_feature("debug")


func _physics_process(delta: float) -> void:
	_process_input()
	
	if in_water:
		_move_water(delta)
	else:
		_move_land(delta)


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
	
	# Toggle water/land movement
	if Input.is_action_just_pressed(&"debug_modeswitch"):
		in_water = !in_water


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Mouselook
		var mouse_motion:InputEventMouseMotion = event as InputEventMouseMotion # get mouse motion
		neck_h.rotation_degrees.y -= mouse_motion.relative.x * MOUSE_SENS
		neck_v.rotation_degrees.x -= mouse_motion.relative.y * MOUSE_SENS
		neck_v.rotation_degrees.x = clamp(neck_v.rotation_degrees.x, -VLOOK_BOUNDS, VLOOK_BOUNDS)
