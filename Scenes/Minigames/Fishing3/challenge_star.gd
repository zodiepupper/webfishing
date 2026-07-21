extends Button

var value = 0
var time_left = 120
var active = true
var des_scale = Vector2()

signal _expired

func _ready():
	rect_scale = Vector2(0.1, 0.1)

func _physics_process(delta):
	if active:
		time_left -= 1
		$TextureProgress.value = time_left
	else:
		$TextureProgress.visible = false
	
	des_scale.x = (sin(OS.get_ticks_msec() * 0.01) * 0.15) + 1.0
	des_scale.y = (sin(OS.get_ticks_msec() * 0.01) * 0.15) + 1.0
	rect_scale = lerp(rect_scale, des_scale, 0.6)
	rect_rotation = (sin(OS.get_ticks_msec() * 0.005) * 5)
	
	if time_left <= 0:
		GlobalAudio._play_sound("hort_lose")
		emit_signal("_expired")
		queue_free()

func _on_challenge_star_pressed():
	if not active: return
	active = false
	
	PlayerData.emit_signal("_play_sfx", "cash" + str(randi() % 2 + 1))
	PlayerData._send_notification("Got $" + str(value) + "!")
	PlayerData.money += value
	
	self_modulate.a = 0.0
	$stars.restart()
	
	yield(get_tree().create_timer(3.0), "timeout")
