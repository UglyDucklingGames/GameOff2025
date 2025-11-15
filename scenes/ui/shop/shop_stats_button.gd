class_name ShopStatsButton extends VBoxContainer

@onready var upgrade_name: Label = %UpgradeName
@onready var new_stat: Label = %NewStat
@onready var current_stat: Label = %CurrentStat
@onready var buy_button: Button = %BuyButton

var _stat:Stat
var _price:int

## Set stat and update text.
func set_stat(stat:Stat) -> void:
	_stat = stat
	update_text()

## Update buy button text.
func update_text() -> void:
	var index:int = _stat.get_current_stat_level()+1
	
	if !_stat.is_fully_upgraded():
		# Next upgrade
		upgrade_name.text = _stat.get_name_at(index)
		new_stat.text = "Upgrade "+_stat.get_stat_name()+ " to " + _stat.get_data_at_as_string(index) + _stat.get_units_string()
		buy_button.text = _stat.get_price_at_as_string(index)
	else:
		upgrade_name.text = _stat.get_stat_name().capitalize() # show name of stat
		new_stat.text = "No upgrades available"
		buy_button.hide() # hide buy button
	
	# Current value
	current_stat.text = "Current: " + _stat.get_current_data_as_string() + _stat.get_units_string()
	
	_price = int(_stat.get_price_at(index))


func _on_buy_button_pressed() -> void:
	# Buy upgrade
	if PlayerData.get_money() >= _price:
		PlayerData.subtract_money(_price)
		_stat.upgrade()
		update_text()
	# Get upgrade instantly
	elif Input.is_action_pressed(&"debug_instabuy") and OS.has_feature("debug"):
		_stat.upgrade()
		update_text()
