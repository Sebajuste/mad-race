extends Node

var enable := false

var linear_velocity : Vector3
var angular_velocity: Vector3
var transform: Transform = Transform()

var updated := false

var current_time := 0.0
var packet_time := 0.0

var last_control := {
	"steer": 0.0,
	"throttle": 0.0,
	"brake": 0.0
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	current_time += delta


func control(delta) -> Dictionary:
	
	
	return last_control


func integrate_forces(state: PhysicsDirectBodyState):
	
	if not updated:
		return
	
	state.linear_velocity = linear_velocity
	state.angular_velocity = angular_velocity
	state.transform = transform
	
	updated = false


puppet func sync_vehicule(packet_frequency: int, packet: Dictionary, controls):
	
	var last_packet_time = packet_time    # remember when last packet arrived
	packet_time = current_time    # get this by summing 'delta' each _process
	var elapsed_time = packet_time - (last_packet_time + (packet_frequency / 1000.0) )
	
	
	linear_velocity = packet.linear_velocity
	angular_velocity = packet.angular_velocity
	transform = packet.transform
	
	# Jitter correction
	packet.transform.origin = packet.transform.origin + linear_velocity * elapsed_time    # project out received position
	
	
	last_control = controls
	
	#$OriginTween.interpolate_property(self, "transform/origin", transform.origin, packet.transform.origin, 0.1)
	
	updated = true
