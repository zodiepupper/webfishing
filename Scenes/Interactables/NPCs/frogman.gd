extends Spatial

func _physics_process(delta):
	scale.y = 0.993 + (sin(OS.get_ticks_msec() * 0.002) * 0.007)



