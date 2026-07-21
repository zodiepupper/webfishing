extends Control

var pairing

func _physics_process(delta):
	if is_instance_valid(pairing):
		if pairing.health <= 0:
			queue_free()
			return
		
		$Panel / Label.text = str(pairing.health)
		rect_global_position = pairing.rect_global_position
		
		
		var p = pairing.health / pairing.max_health
		
		if p < 0.25:
			$TextureRect.modulate = "#ac0029"
			$Panel.get("custom_styles/panel").bg_color = "#ac0029"
		elif p < 0.5:
			$TextureRect.modulate = "#c54400"
			$Panel.get("custom_styles/panel").bg_color = "#c54400"
		elif p < 0.75:
			$TextureRect.modulate = "#e69d00"
			$Panel.get("custom_styles/panel").bg_color = "#e69d00"
		
	else:
		queue_free()
