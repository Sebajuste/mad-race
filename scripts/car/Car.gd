extends VehicleBody

signal speed_changed(value)
signal motor_rpm_changed(value)
signal brake_changed(value)

export(String, "Player", "None") var control_handler := "None" setget set_control_handler

export var MAX_STEER_ANGLE = 0.35
export var STEER_SPEED = 1.0

#export var engine_curve : Curve = Curve.new()
export var ENGINE_MAX_RPM := 6000
export var ENGINE_NEWTON_METERS_MAX := 450
export var ENGINE_ACCEL := 2000.0
export var ENGINE_DECEL := 4000.0

export var MAX_BRAKE_FORCE = 10.0

export var gear_ratios : PoolRealArray = PoolRealArray() setget _set_gear_ratios
export var torque_curve : Curve = Curve.new() setget _set_torque_curve


var steer_angle := 0.0

var last_pos := Vector3()

var current_speed_mps := 0.0


var brakes := false


var reset_forces := false

# Called when the node enters the scene tree for the first time.
func _ready():
	
	last_pos = translation
	
	set_control_handler(control_handler)
	_set_gear_ratios(gear_ratios)
	_set_torque_curve(torque_curve)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	$MotorSound.pitch_scale = 1.0 + ($MotorController.rpm / $MotorController.MAX_RPM) * 3.0
	


func _physics_process(delta):
	
	current_speed_mps = (translation - last_pos).length() / delta
	
	var control_handler = $ControlHandlers.get_current_handler()
	
	var controls = control_handler.control(delta)
	
	if Network.is_enable():
		controls = $CarNetworkSync.update_controls(controls)
	
	if controls.has("steer"):
		$WheelController.steer_val = controls["steer"]
	
	if controls.has("throttle"):
		$MotorController.throttle_val = controls["throttle"]
	
	if controls.has("brake"):
		$WheelController.brake_val = controls["brake"]
	
	
	if( last_pos != translation ):
		emit_signal("speed_changed", linear_velocity.length() * 3.6)
	
	emit_signal("motor_rpm_changed", $MotorController.rpm )
	
	last_pos = translation
	


func _integrate_forces(state: PhysicsDirectBodyState):
	
	if reset_forces:
		state.linear_velocity = Vector3()
		state.angular_velocity = Vector3()
		reset_forces = false
	
	$CarNetworkSync.integrate_forces(state)
	


func set_control_handler(value: String):
	control_handler = value
	$ControlHandlers.handler = control_handler


func _set_gear_ratios(value):
	gear_ratios = value
	if get_node("GearControler") != null:
		$GearController.gear_ratios = value


func _set_torque_curve(value):
	torque_curve = value
	if get_node("MotorControler") != null:
		$MotorController.torque_curve = value
