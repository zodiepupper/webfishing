extends Area

func _on_bush_particle_detect_body_entered(body):
	if body.is_in_group("player"):
		$Particles.restart()
		$AudioStreamPlayer3D.play()
