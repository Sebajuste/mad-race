extends Control


var player_item = preload("PlayerItem.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	
	Network.connect("properties_created", self, "_properties_created")
	Network.connect("property_changed", self, "_property_changed")
	
	
	for peer_id in Network.player_info:
		var properties = Network.player_info[peer_id]
		if properties != null:
			_properties_created(peer_id, properties)
		else:
			_properties_created(peer_id, {})


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _properties_created(peer_id: int, properties: Dictionary):
	var item = player_item.instance()
	item.set_name( str(peer_id) )
	if properties.has("username"):
		item.get_node("Username").text = properties.username
	else:
		item.get_node("Username").text = "New player"
	$VBoxContainer.add_child(item)


func _property_changed(peer_id: int, key: String, value):
	if key == "username":
		var str_peer_id = str(peer_id)
		if $VBoxContainer.has_node(str_peer_id):
			var item = $VBoxContainer.get_node( str(peer_id) )
			item.get_node("Username").text = value


func _player_disconnected(peer_id):
	var str_peer_id = str(peer_id)
	if $VBoxContainer.has_node(str_peer_id):
		var item = $VBoxContainer.get_node( str(peer_id) )
		item.queue_free()
