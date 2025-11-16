extends Node

var _money:int = 0

## Add money to the player's bank.
func add_money(value:int) -> void:
	_money += max(value, 0) # add to running money count (if above 0)
## Remove money from the player's bank.
func subtract_money(value:int) -> void:
	_money -= max(value, 0) # remove from running money count (if above 0)
## Get player's total money.
func get_money() -> int:
	return _money
## Reset player's total money.
func reset_money() -> void:
	_money = 0


# Stats
var _stat_speed:Stat = Stat.new("res://data/player/stat_speed_tiers.json", "swimming speed", "m/s")
var _stat_oxygen:Stat = Stat.new("res://data/player/stat_oxygen.json", "oxygen capacity", " seconds")

var _stats:Array[Stat] = [ # array of all stats
	_stat_speed,
	_stat_oxygen
]

## Get array of all stats.
func get_stats() -> Array[Stat]:
	return _stats.duplicate() # disallow modification
func get_stat_speed() -> Stat:
	return _stat_speed
func get_stat_oxygen() -> Stat:
	return _stat_oxygen
