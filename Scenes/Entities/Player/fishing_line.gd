extends Spatial

export var end_anchor = Vector3( - 2, 0, 0)
export var y_drop = 0.25

var line_scale = 1.0

var active = false

onready var points = $points

func _physics_process(delta):
	if not active: return
	
	var segments = 8.0
	var mid = 3.0
	var offset = (global_transform.origin - end_anchor) / segments
	var ref = [0.0, 0.15, 0.25, 0.32, 0.35, 0.32, 0.25, 0.15, 0.0]
	
	var index = 0
	for segment in points.get_children():
		var mid_dist = ref[index] * y_drop
		var next_mid_dist = ref[index + 1] * y_drop
		
		var point_a = global_transform.origin - (offset * index) + Vector3(0, mid_dist, 0)
		var point_b = global_transform.origin - (offset * (index + 1)) + Vector3(0, next_mid_dist, 0)
		if index == int(segments - 1): point_b = end_anchor
		segment.global_transform.origin = point_a
		segment.look_at(point_b, Vector3.UP)
		segment.rotation_degrees.x -= 90
		segment.scale.y = point_a.distance_to(point_b) * (1.0 + (1.0 - line_scale))
		
		index += 1
