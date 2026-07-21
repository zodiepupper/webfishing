extends Path

func _physics_process(delta):
	var offs = curve.get_closest_offset(get_viewport().get_camera().global_transform.origin)
	$PathFollow.offset = lerp($PathFollow.offset, offs, 0.1)
