extends Control

var stats_button:PackedScene = load("res://scenes/ui/shop/shop_stats_button.tscn")
@onready var stats_container: VBoxContainer = %Stats

var _enabled:bool = false


func _ready() -> void:
	_create_stat_buttons()
	
	set_enabled(false)


## Create an upgrade button for each extant stat.
func _create_stat_buttons() -> void:
	var stats:Array[Stat] = PlayerData.get_stats()
	
	for n:int in stats.size():
		var sb:ShopStatsButton = stats_button.instantiate()
		stats_container.add_child(sb)
		
		sb.set_stat(stats[n])


## Enable or disable the shop.
func set_enabled(to:bool) -> void:
	_enabled = to
	
	visible = _enabled
	
	if _enabled:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"temp_shop"):
		set_enabled(!_enabled)
