extends WorldEnvironment

const DAY_INCREMENT:float = 0.0001 # time to increase by

var _day_progress:float = 0.1 # progress (0-1)


## Advance time.
func _increment_time() -> void:
	# Increment day progress and wrap after 1.0
	_day_progress = wrapf(_day_progress + DAY_INCREMENT, 0.0, 1.0)
	
	# Update sky colour
	var shader:ShaderMaterial = environment.sky.sky_material
	shader.set_shader_parameter("day_progress", _day_progress)


func _on_timer_timeout() -> void:
	_increment_time()
