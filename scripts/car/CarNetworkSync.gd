extends Node

export var sync_frequency := 0.1

export var motor_controller_path : NodePath
export var gear_controller_path : NodePath
export var wheel_controller_path : NodePath


var motor_controller
var gear_controller
var wheel_controller



var last_state : Dictionary
var last_controls : Dictionary

var need_update := false

var need_interpolate := false
var interpolate_start_pos : Vector3
var interpolate_end_pos : Vector3
var interpolate_t := 0.0

var current_time := 0.0
var packet_time := 0.0


var packet_id := 0
var last_packet_id_received := 0

var packet_delta := 0



# Called when the node enters the scene tree for the first time.
func _ready():
	
	motor_controller = get_node(motor_controller_path)
	gear_controller = get_node(gear_controller_path)
	wheel_controller = get_node(wheel_controller_path)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	current_time += delta
	
	if need_interpolate:
		interpolate_t += delta
	


func update_controls(controls: Dictionary) -> Dictionary:
	
	if is_network_master():
		last_controls = controls
		return controls
	elif last_controls != null:
		return last_controls
	else:
		return controls
	


func integrate_forces(state: PhysicsDirectBodyState):
	
	if not Network.is_enable():
		return
	
	if is_network_master():
		
		last_state = {
			"linear_velocity": state.linear_velocity,
			"angular_velocity": state.angular_velocity,
			"transform": state.transform,
		}
		
		pass
	else:
		
		if need_update:
			state.linear_velocity = last_state.linear_velocity
			state.angular_velocity = last_state.angular_velocity
			state.transform.basis = last_state.transform.basis
			
			var delta_pos = state.transform.origin - last_state.transform.origin
			if delta_pos.length() > 1.0:
				need_interpolate = true
				interpolate_start_pos = state.transform.origin
				interpolate_end_pos = last_state.transform.origin
				interpolate_t = 0.0
				pass
			elif delta_pos.length() > 0.1:
				state.transform.origin = last_state.transform.origin
				need_interpolate = false
			
			need_update = false
		
		
		if need_interpolate:
			var t = interpolate_t / ( packet_delta * sync_frequency )
			state.transform.origin = interpolate_start_pos.linear_interpolate(interpolate_end_pos, t)
			var delta_pos = state.transform.origin - interpolate_end_pos
			if delta_pos.length() < 0.01:
				need_interpolate = false
		
		
		pass
	
	pass


master func sync_vehicule():
	
	if not Network.is_enable() or not is_network_master():
		return
	
	var rpm = 0
	if motor_controller != null:
		rpm = motor_controller.rpm
	
	var gear = 0
	if gear_controller != null:
		gear = gear_controller.get_gear()
	
	var steer_angle := 0.0
	if wheel_controller != null:
		steer_angle = wheel_controller.steer_angle
	
	if last_state != null and last_controls != null:
		
		var byte_buffer := NetByteBuffer.new(64)
		
		var write_stream := NetStreamWriter.new(byte_buffer)
		
		packet_id = packet_id + 1
		write_stream.serialize_bits(packet_id, 32) # frequency
		write_stream.serialize_bits(sync_frequency * 1000, 8) # frequency
		
		
		var properties := {
			"linear_velocity": last_state["linear_velocity"],
			"angular_velocity": last_state["angular_velocity"],
			"transform": last_state["transform"],
			"rpm": rpm,
			"gear": gear,
			"steer_angle": steer_angle,
			"steer": last_controls.steer,
			"throttle": last_controls.throttle,
			"brake": last_controls.brake,
		}
		
		serialize(write_stream, properties)
		
		
		
		write_stream.flush()
		byte_buffer.flip()
		
		var byte_packet : PoolByteArray = byte_buffer.array()
		byte_packet.resize( byte_buffer.limit() )
		
		#print("send byte_packet [%d]: " % byte_buffer.limit(), NetUtils.byte_buffer_to_str(byte_buffer) )
		
		rpc_unreliable("sync_vehicule_reception", byte_packet)
	
	pass


puppet func sync_vehicule_reception(byte_packet : PoolByteArray ):
	
	var last_packet_time := packet_time
	packet_time = current_time
	
	var read_buffer := NetUtils.byte_buffer_from_byte_array(byte_packet)
	var read_stream := NetStreamReader.new(read_buffer)
	
	read_stream.serialize_bits(packet_id, 32) # frequency
	var packet_frequency : float = read_stream.serialize_bits(0, 8) / 1000.0 # frequency
	
	packet_delta = packet_id - last_packet_id_received
	if packet_delta == 0:
		packet_delta = 1
	
	var except_packet_time = last_packet_time + packet_delta * packet_frequency
	
	var jitter_time = current_time - except_packet_time
	
	
	var properties := {
		"linear_velocity": Vector3(),
		"angular_velocity": Vector3(),
		"transform": Transform()
	}
	
	serialize(read_stream, properties)
	
	last_packet_id_received = packet_id
	
	# Jitter correction
	if jitter_time > 0:
		properties.transform.origin = properties.transform.origin + properties.linear_velocity * jitter_time    # project out received position
	
	
	last_state["linear_velocity"] = properties.linear_velocity
	last_state["angular_velocity"] = properties.angular_velocity
	last_state["transform"] = properties.transform
	
	
	last_controls = properties
	
	if motor_controller != null:
		motor_controller.rpm = properties.rpm
	
	if gear_controller != null:
		gear_controller.gear_index = properties.gear
	
	if wheel_controller != null:
		wheel_controller.steer_angle = properties.steer_angle
	
	need_update = true


func serialize(stream : NetStream, properties: Dictionary ):
	
	# Serialize physics
	properties.linear_velocity = NetStream.serialize_vector3_dir(stream, properties.linear_velocity, 100.0, 0.01)
	properties.angular_velocity = NetStream.serialize_vector3_dir(stream, properties.angular_velocity, 20.0, 0.01)
	
	var quat := Quat( properties.transform.basis )
	quat = NetStream.serialize_quat(stream, quat)
	properties.transform.basis = Basis( quat )
	
	properties.transform.origin = NetStream.serialize_vector3(stream, properties.transform.origin, -20.0, 500.0, 0.001)
	
	
	# Serialize controls
	var throttle := 0.0
	if properties.has("throttle"):
		throttle = properties.throttle
	properties.throttle = NetStream.serialize_float(stream, throttle, -1.0, 1.0, 0.1)
	
	var steer := 0.0
	if properties.has("steer"):
		steer = properties.steer
	properties.steer = NetStream.serialize_float(stream, steer, -1.0, 1.0, 0.1)
	
	var brake := 0.0
	if properties.has("brake"):
		brake = properties.brake
	properties.brake = NetStream.serialize_float(stream, brake, -1.0, 1.0, 0.1)
	
	
	# Serialize modules info
	var rpm := 0
	if properties.has("rpm"):
		rpm = properties.rpm
	properties["rpm"] = NetStream.serialize_int(stream, rpm, 0, motor_controller.MAX_RPM )
	
	var gear := 0
	if properties.has("gear"):
		gear = properties.gear
	properties["gear"] = NetStream.serialize_int(stream, gear, -1, 10)
	
	var steer_angle := 0.0
	if properties.has("steer_angle"):
		steer_angle = properties.steer_angle
	properties["steer_angle"] = NetStream.serialize_float(stream, steer_angle, -30.0, 30.0, 0.1)
	

