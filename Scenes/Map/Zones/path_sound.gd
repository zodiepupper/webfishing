extends Path3D

func _physics_process(delta):
	var offs = curve.get_closest_offset(get_viewport().get_camera_3d().global_transform.origin)
	$PathFollow3D.offset = lerp($PathFollow3D.offset, offs, 0.1)
