extends Spatial

export var creation_time = Vector2(2.0, 12.0)
export var _range = Vector3()

func _on_Timer_timeout():
	$Timer.stop()
	$Timer.wait_time = rand_range(creation_time.x, creation_time.y)
	$Timer.start()
	
	var count = randi() % 2 + 1
	for i in count:
		var wind = preload("res://Scenes/Map/Props/wind_particles.tscn").instance()
		add_child(wind)
		wind.global_transform.origin = global_transform.origin + Vector3(\
		rand_range( - _range.x, _range.x), \
		rand_range( - _range.y, _range.y), \
		rand_range( - _range.z, _range.z))
		
		wind.rotation_degrees.y = randi() % 360
		
		
		var s = rand_range(0.4, 0.8)
		wind.scale.x = s
		wind.scale.y = s
		wind.scale.z = s
