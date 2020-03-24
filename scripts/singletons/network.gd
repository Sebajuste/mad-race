extends Node

signal property_changed(id, key, value)

var enable := false

var player_info : Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func is_enable() -> bool:
	return enable


func set_property(key: String, value):
	
	rpc("_set_property", key, value)
	


func get_property(peer_id: int, key: String):
	if player_info.has(peer_id):
		var info = player_info[peer_id]
		return info[key]
	return null


func erase_property(key: String):
	
	rpc("_erase_property", key)
	


func get_self_peer_id() -> int:
	
	return get_tree().get_network_unique_id()
	


func broadcast(res: Node, method: String, args: Array):
	var self_peer_id = get_self_peer_id()
	for peer_id in player_info:
		if self_peer_id != peer_id:
			res.rpc(method, args)


func _player_connected(id: int):
	
	print("_player_connected ", id)
	
	rpc_id(id, "_register_player")


func _player_disconnected(id: int):
	
	print("_player_disconnected ", id)
	
	player_info.erase(id)


func _connected_ok():
	enable = true
	print("_connected_ok")
	pass


func _connected_fail():
	enable = false
	print("_connected_fail")
	
	pass


func _server_disconnected():
	enable = false
	print("_server_disconnected")
	
	player_info.clear()


remotesync func _register_player():
	var id = get_tree().get_rpc_sender_id()
	player_info[id] = {}
	


remotesync func _set_property(key: String, value):
	var id = get_tree().get_rpc_sender_id()
	var info = player_info[id]
	info[key] = value
	
	emit_signal("property_changed", id, key, value)


remotesync func _erase_property(key: String):
	var id = get_tree().get_rpc_sender_id()
	var info : Dictionary = player_info[id]
	info.erase(key)
