extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var pos = global_transform.origin
	pos.y += 2
	var cam = get_tree().get_root().get_camera()
	var cam_dir = (cam.global_transform.origin - global_transform.origin).normalized()
	var cam_dot = cam_dir.dot( cam.global_transform.basis.z )
	if cam_dot > 0.0:
		var screen_pos = cam.unproject_position(pos)
		$Control.set_position( Vector2(screen_pos.x - $Control.rect_size.x/2, screen_pos.y-60) )
		$Control.visible = true
	else:
		$Control.visible = false
