## Handler for a statistic
class_name Stat extends RefCounted

signal upgraded

var _stat_name:String = "stat name" # e.g speed
var _units_string:String = " units" # e.g m/s
var _number_formatting:String = "%1d" # formatting for stat values

var _data:Array
var _current_stat_level:int = 0 # progression level of stat


## Create a new stat.
## [br][br]
## [param data_filepath] Path to JSON data file.
## [br][br]
## [param stat_name] Name of the stat e.g. "speed", "health".
## [br][br]
## [param units_string] Unit string format e.g. " seconds", "m/s".
## [br][br]
## [param number_formatiing] Formatting for stat values.
func _init
(
	data_filepath:String,
	stat_name:String, 
	units_string:String = " units", 
	number_formatting:String = "%1d"
) -> void:
	
	# Set stat values
	_stat_name = stat_name
	_units_string = units_string
	_number_formatting = number_formatting
	
	_data = JSONParser.parse(data_filepath)["stats"] # get data


## Upgrade this stat by one level.
func upgrade() -> void:
	if !is_fully_upgraded():
		_current_stat_level += 1
		upgraded.emit() # emit signal

func is_fully_upgraded() -> bool:
	return _current_stat_level + 1 >= _data.size()


## Get raw data value for the current statistic.
func get_current_data() -> float:
	return _data[_current_stat_level]["data"]

## Get raw data value at a specific index.
func get_data_at(index:int) -> float:
	if index <= 0 or index >= _data.size(): return 0.0 # if invalid index
	return _data[index]["data"]

## Get current data value as a formatted string.
func get_current_data_as_string() -> String:
	return _number_formatting%get_current_data()

## Get data value at a specific index as a formatted string.
func get_data_at_as_string(index:int) -> String:
	return _number_formatting%get_data_at(index)


## Get name for the current statistic.
func get_current_name() -> String:
	return _data[_current_stat_level]["name"]

## Get name at a specific index.
func get_name_at(index:int) -> String:
	if index <= 0 or index >= _data.size(): return "" # if invalid index
	return _data[index]["name"]


## Get price value for the current statistic.
func get_current_price() -> float:
	return _data[_current_stat_level]["value"]

## Get price value at a specific index.
func get_price_at(index:int) -> float:
	if index <= 0 or index >= _data.size(): return 0.0 # if invalid index
	return _data[index]["value"]

## Get current price value as a formatted string.
func get_current_price_as_string() -> String:
	return "$" + "%1d"%get_current_price()

## Get price value at a specific index as a formatted string.
func get_price_at_as_string(index:int) -> String:
	return "$" + "%1d"%get_price_at(index)



# -- Private variable getters --

func get_stat_name() -> String:
	return _stat_name
func get_units_string() -> String:
	return _units_string
func get_current_stat_level() -> int:
	return _current_stat_level
