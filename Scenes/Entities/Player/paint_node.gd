extends Spatial

var drawing = false
var size = 1
var color = 0

func _paint_process(delta):
	if drawing:
		var final_size = size
		if Input.is_action_pressed("move_sneak"):
			final_size = ceil(size / 2.0)
		if Input.is_action_pressed("move_sprint"):
			final_size = ceil(size * 2.0)
		
		PlayerData.emit_signal("_chalk_draw", global_transform.origin, final_size, color)
	else:
		PlayerData.emit_signal("_chalk_update", global_transform.origin)
