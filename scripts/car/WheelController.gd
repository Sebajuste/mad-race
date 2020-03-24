extends Node


signal brake_changed(is_brakes)

export var MAX_STEER_ANGLE := 0.5
export var STEER_SPEED = 1.0

export var MAX_BRAKE_FORCE := 10.0


var steer_val := 0.0
var brake_val := 0.0

var is_brakes := false
var steer_angle := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _physics_process(delta):
	
	var linear_velocity = $"../".linear_velocity
	
	var max_angle = MAX_STEER_ANGLE * ( 1.0 / ( (linear_velocity.length() ) / 10.0 + 1.0) )
	
	var steer_target = steer_val * max_angle
	
	if (steer_target < steer_angle):
		steer_angle -= STEER_SPEED * delta
		if (steer_target > steer_angle):
			steer_angle = steer_target
	elif (steer_target > steer_angle):
		steer_angle += STEER_SPEED * delta
		if (steer_target < steer_angle):
			steer_angle = steer_target
	
	$"../".steering = steer_angle
	
	
	if brake_val > 0.1:
		if not is_brakes:
			is_brakes = true
			emit_signal("brake_changed", is_brakes)
		
	elif is_brakes:
		is_brakes = false
		emit_signal("brake_changed", is_brakes)
	
	$"../".brake = brake_val * MAX_BRAKE_FORCE
	
	
	


func get_rpm() -> float:
	
	return $"../right_rear".get_rpm()
	


puppet func sync_wheels(value):
	steer_angle = value
