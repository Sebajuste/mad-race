extends Camera


export var target_path : NodePath setget _set_target_path
export var target_height := 2.0

export var distance := 5.0
export var height := 2.0

var target: Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass

func _physics_process(delta):
	
	if not target:
		return
	
	var offset : Vector3 = global_transform.origin - target.global_transform.origin
	offset = offset.normalized() * distance
	offset.y = height
	
	var pos = target.global_transform.origin + offset
	var target_pos = target.global_transform.origin
	target_pos.y += target_height
	
	look_at_from_position(pos, target_pos, Vector3.UP)
	


func _set_target_path(v: NodePath):
	target_path = v
	if target_path:
		target = get_node(target_path)
