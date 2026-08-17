extends Button

var value = 0
var time_left = 120
var active = true
var des_scale = Vector2()

signal _expired

func _ready():
	scale = Vector2(0.1, 0.1)

func _physics_process(delta):
	if active:
		time_left -= 1
		$TextureProgressBar.value = time_left
	else:
		$TextureProgressBar.visible = false
	
	des_scale.x = (sin(Time.get_ticks_msec() * 0.01) * 0.15) + 1.0
	des_scale.y = (sin(Time.get_ticks_msec() * 0.01) * 0.15) + 1.0
	scale = lerp(scale, des_scale, 0.6)
	rotation = (sin(Time.get_ticks_msec() * 0.005) * 5)
	
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
	
	await get_tree().create_timer(3.0).timeout
