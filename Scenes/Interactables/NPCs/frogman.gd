extends Node3D

func _physics_process(delta):
	scale.y = 0.993 + (sin(Time.get_ticks_msec() * 0.002) * 0.007)



