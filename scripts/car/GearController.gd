extends Node


signal gear_changed(gear)

export var gear_ratios := PoolRealArray()


var gear_index := 0 setget _set_gear_index

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if gear_ratios.size() > 1:
		_set_gear_index(1)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func get_gear() -> int:
	return gear_index


func get_current_gear_ratio() -> float:
	if not gear_ratios.empty():
		return gear_ratios[gear_index]
	return 0.0


func gear_up() -> int:
	if gear_index < gear_ratios.size() - 1:
		gear_index += 1
		emit_signal("gear_changed", gear_index)
	return gear_index


func gear_down() -> int:
	if gear_index > 0:
		gear_index -= 1
		emit_signal("gear_changed", gear_index)
	return gear_index


puppet func _set_gear_index(value):
	gear_index = value
	emit_signal("gear_changed", gear_index)
