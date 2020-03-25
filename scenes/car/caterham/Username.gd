extends Label



var peer_id


# Called when the node enters the scene tree for the first time.
func _ready():
	
	Network.connect("property_changed", self, "_property_changed")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Caterham_renamed():
	
	peer_id = $"../../../".name
	
	var username = Network.get_property( int(peer_id), "username")
	if username != null:
		self.text = username
	
	pass # Replace with function body.


func _property_changed(id, key, value):
	if str(id) == peer_id and key == "username":
		self.text = value
