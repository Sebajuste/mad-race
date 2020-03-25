extends MarginContainer

signal exited
signal lobby_started


const MAX_PLAYERS := 8

onready var username = $Panel/MarginContainer/VBoxContainer/Username/LineEdit

onready var host_address = $Panel/MarginContainer/VBoxContainer/Content/TabContainer/Join/VBoxContainer/IPAddress/Value
onready var host_port = $Panel/MarginContainer/VBoxContainer/Content/TabContainer/Join/VBoxContainer/Port/Value

onready var server_port = $Panel/MarginContainer/VBoxContainer/Content/TabContainer/Create/VBoxContainer/Port/Value


var upnp = UPNP.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	
	get_tree().connect("connected_to_server", self, "_connected_ok")
	
	upnp.discover()
	
	var external_address = upnp.query_external_address()
	$Panel/MarginContainer/VBoxContainer/Content/TabContainer/Create/VBoxContainer/IPAddress/Value.text = external_address
	
	randomize()
	username.text = "Player_%d" % randi()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ReturnButton_pressed():
	
	emit_signal("exited")
	


func _on_JoinButton_pressed():
	
	var ip = host_address.text
	var port = int( host_port.text )
	
	var peer = NetworkedMultiplayerENet.new()
	var result = peer.create_client(ip, port)
	
	if result != OK:
		return
	
	get_tree().set_network_peer(peer)
	
	#emit_signal("lobby_started")
	
	pass # Replace with function body.


func _on_CreateButton_pressed():
	
	var port = int( server_port.text )
	
	var peer = NetworkedMultiplayerENet.new()
	var result = peer.create_server(port, MAX_PLAYERS)
	
	if result != OK:
		return
	
	get_tree().set_network_peer(peer)
	
	Network.enable = true
	
	upnp.add_port_mapping(port, port, "RaceGame", "UDP", 3600)
	
	print("Server started", result)
	
	Network.set_property("username", username.text)
	emit_signal("lobby_started")


func _connected_ok():
	
	Network.set_property("username", username.text)
	emit_signal("lobby_started")
	
