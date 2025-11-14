extends Node

var _money:int = 0

## Add money to the player's bank.
func add_money(value:int) -> void:
	_money += max(value, 0) # add to running money count (if above 0)
## Get player's total money.
func get_money() -> int:
	return _money
## Reset player's total money.
func reset_money() -> void:
	_money = 0
