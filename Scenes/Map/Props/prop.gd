extends PropVis

@export var random_rot = true
@export var random_scale = true
@export var scale_min = 1.0
@export var nudge = 0.0

func _ready():
	var pos_val = global_transform.origin.x * 100.0 + \
	global_transform.origin.y * 100.0 + \
	global_transform.origin.z * 100.0
	
	if random_rot:
		rotation_degrees.y = rotation_degrees.y + (sin(pos_val) * 180)
	
	if random_scale:
		var new_scale = (scale_min + (sin(pos_val) * 0.15))
		scale = Vector3(new_scale, new_scale, new_scale)
	
	if nudge != 0.0:
		position.y += nudge
