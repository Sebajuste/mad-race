extends Node

class_name DefaultControlHandler


var enable := false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func control(delta) -> Dictionary:
	
	#print("DefaultControlHandler")
	
	var result := {
		"steer": 0.0,
		"throttle": 0.0,
		"brake": 0.0
	}
	
	return result


func integrate_forces(state: PhysicsDirectBodyState):
	pass
