extends Spatial

func _open():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("in")

func _close():
	$AnimationPlayer.stop()
	$AnimationPlayer.play_backwards("in")

func _physics_process(delta):
	$Spatial.translation.y = sin(OS.get_ticks_msec() * 0.0007) * 0.02

