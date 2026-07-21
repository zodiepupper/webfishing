extends Minigame

const max_difficulty = 20.0

var cursor_pos = 0.0
var bar_pos = 0.0
var bar_pull = 0.0
var bar_size = 0
var dead_zone = 0
var dead_rate = 0
var health = 0
var mode = 0
var bar_mash = 3

var dif_chance = 0.0
var dif_length = 0.0
var dif_speed = 0.0
var cur_pull = 0
var pl_speed = 1.7
var snap_chance = 0.0

var attempts = 0

var shake = 0

onready var cursor = $Control / bar
onready var bar_top = $Control / frame / bartop
onready var bar_bot = $Control / frame / barbot
onready var dead_line = $Control / frame / red
onready var root = $Control
onready var bar_wipe = $Control / frame / bar_wipe
onready var hp_bar = $Control / TextureRect / TextureProgress
onready var hp_prog = $Control / TextureRect / prog
onready var bg = $Control / frame / bg
onready var hplabel = $Control / TextureRect / Label



func _ready():
	var diff = min(difficulty, max_difficulty)
	var calc = (diff / max_difficulty)
	
	health = round(4 * diff)
	bar_size = clamp(68 - (38 * calc), 24, 120)
	pl_speed = 1.7 - (calc * 0.3)
	attempts = 0
	
	print(diff, " ", calc)
	_set_diff()
	
	hp_bar.max_value = health
	hp_prog.max_value = health
	bar_size = 64
	cursor_pos = 0.0
	dead_rate = 0.85
	dead_zone = - 100.0
	bar_pos = 32.0
	cursor_pos = 0.0
	mode = 0
	bar_mash = 3
	
	$Control2 / Panel / AnimatedSprite.texture = preload("res://Assets/Textures/UI/countdown1.png")
	yield(get_tree().create_timer(0.7), "timeout")
	$Control2 / Panel / AnimatedSprite.texture = preload("res://Assets/Textures/UI/countdown2.png")
	yield(get_tree().create_timer(0.7), "timeout")
	$Control2 / Panel / AnimatedSprite.texture = preload("res://Assets/Textures/UI/countdown3.png")
	yield(get_tree().create_timer(0.7), "timeout")
	$Control2 / Panel / AnimatedSprite.texture = preload("res://Assets/Textures/UI/countdown4.png")
	mode = 1

func _set_diff():
	var diff = min(difficulty * (1.0 + (attempts * 0.15)), max_difficulty)
	var calc = (diff / max_difficulty)
	
	snap_chance = 0.0 + (attempts * 0.02)
	dif_chance = 0.003 + (calc * 0.003)
	dif_length = 20 - (calc * 12)
	dif_speed = 1.5 + (calc * 0.3)
	
	print(dif_chance, " / ", dif_length, " / ", dif_speed)

func _reset():
	mode = 0
	var tween = get_tree().create_tween()
	tween.set_ease(1)
	tween.tween_property(self, "dead_zone", - 10.0, 1.0)
	tween.parallel().tween_property(self, "bar_pos", 32.0, 1.0)
	tween.parallel().tween_property(self, "cursor_pos", 16.0, 1.0)
	tween.parallel().tween_property(self, "bar_mash", 3.0, 0.5)
	yield(get_tree().create_timer(1.5), "timeout")
	mode = 1

func _physics_process(delta):
	if mode != 0:
		$Control2.modulate.a = lerp($Control2.modulate.a, 0.0, 0.08)
		$Control2 / Panel.rect_position.x = lerp($Control2 / Panel.rect_position.x, - 100, 0.08)
	
	if mode == 1:
		
		if Input.is_action_pressed("primary_action"):
			cursor_pos += 2.7
		else:
			cursor_pos -= 2.2
		cursor_pos = clamp(cursor_pos, 0.0, 484)
		
		if Input.is_action_just_pressed("bind_1"): shake = 20.0
		
		
		var leeway = 6
		bg.material.set_shader_param("offset", Vector2(0, bar_pos))
		
		var in_zone = cursor_pos > (bar_pos - leeway) and cursor_pos < (bar_pos + bar_size + leeway)
		
		if cur_pull <= 0:
			if in_zone:
				bg.material.set_shader_param("motion", Vector2( - 32, - 32))
				bar_pos += pl_speed
			else:
				bg.material.set_shader_param("motion", Vector2(16, 16))
				bar_pos -= 1.2
			
			if randf() <= (dif_chance + (dif_chance * (bar_pos / 495))) and dead_zone > 0.0:
				cur_pull = rand_range(5, dif_length)
		
		else:
			bar_pos -= dif_speed if in_zone else dif_speed * 0.5
			cur_pull -= 1
		
		bar_pos = clamp(bar_pos, 32.0, 495 - bar_size)
		
		var dist_to_end = (495 - bar_size) - bar_pos
		if dist_to_end < 200: shake = (1.0 - dist_to_end / 200.0) * 1.5
		if dist_to_end <= 4: mode = 2
		
		dead_zone += dead_rate
	
	elif mode == 2:
		if Input.is_action_just_pressed("primary_action") and bar_mash > 0:
			shake = ((bar_mash / 3.0) + 0.5) * 10.0
			bar_mash -= 1
		if bar_mash <= 0:
			mode = 0
			_reached_end()
		
		dead_zone += dead_rate
	
	if dead_zone - 10 > bar_pos:
		_dead()
	
	cursor.margin_top = 272 + cursor_pos
	bar_top.rect_size.y = 15 + bar_pos
	bar_bot.rect_size.y = 505 - bar_pos - bar_size
	bar_bot.rect_position.y = 15 + bar_pos + bar_size
	dead_line.value = dead_zone
	bar_wipe.anchor_left = lerp(bar_wipe.anchor_left, (float(bar_mash) / 3.0), 0.8)
	hp_bar.value = health
	hp_prog.value = lerp(hp_prog.value, health, 0.09)
	
	hplabel.text = str(ceil(health))
	
	root.rect_position.x = sin(OS.get_ticks_msec() * 0.02) * shake
	shake = lerp(shake, 0.0, 0.2)

func _reached_end():
	health -= params["damage"]
	health = max(0.0, health)
	if health <= 0:
		shake = 15.0
		$Panel.show()
		$Panel / TextureRect.texture = preload("res://Assets/Textures/UI/winmsg1.png")
		yield(get_tree().create_timer(1.0), "timeout")
		_end(true)
		return
	
	shake = 15.0
	yield(get_tree().create_timer(1.0), "timeout")
	attempts += 1
	_set_diff()
	_reset()

func _dead():
	mode = 0
	shake = 15.0
	
	$Panel.show()
	$Panel / TextureRect.texture = preload("res://Assets/Textures/UI/winmsg2.png")
	yield(get_tree().create_timer(1.0), "timeout")
	_end(false)
