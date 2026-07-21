extends Area

func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		body._mushroom_bounce()
	else:
		return
	
	var tween = get_tree().create_tween()
	tween.tween_property(get_parent(), "scale", Vector3(0.6, 0.6, 0.6), 0.05)
	tween.tween_property(get_parent(), "scale", Vector3(1.0, 1.0, 1.0), 0.5)
	
	$bounce_emit.restart()
	$AudioStreamPlayer3D.play()
