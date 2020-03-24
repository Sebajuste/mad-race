extends Node


signal rpm_changed(rpm)
signal engine_force_changed(value)

export var gear_controller_path : NodePath
export var wheel_controller_path : NodePath

export var torque_curve : Curve #= Curve.new()
export var MIN_RPM := 700
export var MAX_RPM := 8000
export var NEWTON_METERS_MAX := 450
export var ENGINE_ACCEL := 2000.0
export var ENGINE_DECEL := 4000.0


const finalDriveRatio = 3.5

var gear_controller
var wheel_controller

var throttle_val : float = 0.0
var rpm : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	gear_controller = get_node(gear_controller_path)
	wheel_controller = get_node(wheel_controller_path)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _physics_process(delta):
	
	var wheelRPM = wheel_controller.get_rpm()
	
	var gear_val = gear_controller.get_current_gear_ratio()
	
	var accel := throttle_val / 10.0
	
	var local_motor_rpm = MIN_RPM + (wheelRPM * finalDriveRatio * gear_val) + ( accel * finalDriveRatio )
	
	local_motor_rpm = clamp(local_motor_rpm, MIN_RPM, MAX_RPM)
	
	if $Tween != null:
		$Tween.interpolate_property(self, "rpm", rpm, local_motor_rpm, 0.1)
		$Tween.start()
	else:
		rpm = local_motor_rpm
	
	var newton_meters = torque_curve.interpolate(rpm / MAX_RPM) * NEWTON_METERS_MAX
	
	var engine_force = newton_meters * gear_val * finalDriveRatio * accel;
	
	$"../".engine_force = engine_force
	
	
	#print("torque points : ", torque_curve.get_point_count() )
	#print("torque_curve.interpolate(rpm / MAX_RPM): ", torque_curve.interpolate(rpm / MAX_RPM))
	
	emit_signal("rpm_changed", rpm)
	emit_signal("engine_force_changed", engine_force)
	

puppet func sync_motor(rpm):
	$Tween.interpolate_property(self, "rpm", self.rpm, rpm, 0.1)
	$Tween.start()
