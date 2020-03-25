extends Node


var Caterham = preload("res://scenes/car/caterham/Caterham.tscn")



var player_car


# Called when the node enters the scene tree for the first time.
func _ready():
	
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	
	Configuration.connect("configuration_changed", self, "_on_configuration_changed")
	
	player_car = Caterham.instance()
	player_car.control_handler = "Player"
	
	$World.add_child(player_car)
	player_car.transform = $World/Track/StartPositions/Position3D.transform
	player_car.set_network_master( Network.get_self_peer_id() )
	player_car.set_name( str(Network.get_self_peer_id()) )
	
	$World/Camera.target = player_car
	
	player_car.connect("speed_changed", $UI/VehicleInfo, "set_speed")
	player_car.get_node("MotorController").connect("rpm_changed", $UI/VehicleInfo, "set_motor_rpm")
	player_car.get_node("GearController").connect("gear_changed", $UI/VehicleInfo, "set_gear")
	
	load_players()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _input(event):
	
	if Input.is_action_just_pressed("ui_accept"):
		
		player_car.transform = $World/Track/StartPositions/Position3D.transform
		
		player_car.reset_forces = true
		
	
	if Input.is_action_just_pressed("ui_cancel"):
		
		#get_tree().quit()
		
		$UI/OptionsMenu.visible = true
		
		if not Network.is_enable():
			get_tree().paused = true
		
	



func load_players():
	
	for id in Network.player_info:
		_player_connected(id)
	
	pass


func _on_configuration_changed(configuration: Dictionary):
	
	$UI/ControlsHelper.visible = configuration.Game.ControlsHelper
	
	pass


func _player_connected(id: int):
	
	if $World.get_node( str(id) ) != null:
		return
	
	var car = Caterham.instance()
	
	$World.add_child(car)
	car.transform = $World/Track/StartPositions/Position3D.transform
	car.set_network_master( id )
	car.set_name( str(id) )
	
	pass


func _player_disconnected(id: int):
	
	var str_id = str(id)
	
	for child in $World.get_children():
		if child.name == str_id:
			child.queue_free()
			return
	


func _on_Options_closed():
	$UI/OptionsMenu.visible = false
	if not Network.is_enable():
		get_tree().paused = false
	
