extends Node


export var gear_path : NodePath


var enable := false

var gear_node

var elapsed_time := 0.0
var send_packet := false

var force_packet = null


# Called when the node enters the scene tree for the first time.
func _ready():
	
	gear_node = self.get_node(gear_path)
	
	pass # Replace with function body.





func _input(event):
	
	if Input.is_action_just_pressed("gear_up"):
		gear_node.gear_up()
	
	if Input.is_action_just_pressed("gear_down"):
		gear_node.gear_down()


func control(delta) -> Dictionary:
	
	var steer_val := 0.0
	
	if Input.is_action_pressed("ui_right"):
		steer_val = -1.0
	
	if Input.is_action_pressed("ui_left"):
		steer_val = 1.0
	
	var throttle_val := 0.0
	var brake_val := 0.0
	
	if Input.is_action_pressed("ui_up"):
		throttle_val = 1.0
	else:
		brake_val = 0.1
	
	if Input.is_action_pressed("ui_down"):
		brake_val = 1.0
	
	return {
		"steer": steer_val,
		"throttle": throttle_val,
		"brake": brake_val
	}

