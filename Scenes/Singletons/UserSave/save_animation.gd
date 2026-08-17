extends CanvasLayer

var lifetime = 240

func _physics_process(delta):
	$TextureRect.modulate.a = 0.5 + (sin(Time.get_ticks_msec() * 0.01) * 0.25)
	lifetime -= 1
	if lifetime <= 0:
		PlayerData._send_notification("Game Saved.")
		queue_free()
