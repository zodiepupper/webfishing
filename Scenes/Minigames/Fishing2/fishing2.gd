extends Minigame

var progress = 0
var tension = 0
var turn = 0
var pulling = 0
var pull_timer = 30

var tension_speed = 0.52
var tension_slow = 0.07
var progress_speed = 0.34
var release_speed = 0.2
var pull_length = 45
var pull_speed = 0.14
var turn_speed = 0.2
var fake_chance = 0.2



var active = true

func _ready():
	$Control2 / Panel2.hide()
	active = false
	pull_timer = rand_range(45, 200)

	$Control2 / Panel / AnimatedSprite.texture = preload("res://Assets/Textures/UI/countdown1.png")
	yield(get_tree().create_timer(0.7), "timeout")
	$Control2 / Panel / AnimatedSprite.texture = preload("res://Assets/Textures/UI/countdown2.png")
	yield(get_tree().create_timer(0.7), "timeout")
	$Control2 / Panel / AnimatedSprite.texture = preload("res://Assets/Textures/UI/countdown3.png")
	yield(get_tree().create_timer(0.7), "timeout")
	$Control2 / Panel / AnimatedSprite.texture = preload("res://Assets/Textures/UI/countdown4.png")
	active = true

func _physics_process(delta):
	if active:
		$Control2.modulate.a = lerp($Control2.modulate.a, 0.0, 0.08)
		$Control2 / Panel.rect_position.x = lerp($Control2 / Panel.rect_position.x, - 100, 0.08)
	
	var total = 0.0
	
	if active:
		pull_timer -= 1
		if pull_timer <= 0:
			if randf() < fake_chance:
				pulling = 2
				pull_timer = rand_range(45, 200) + pull_length
			else:
				pulling = pull_length
				pull_timer = rand_range(45, 200) + pull_length
		
		turn = lerp(turn, float(pulling > 0), turn_speed)
		
		if pulling > 0 and turn >= 0.9:
			total -= pull_speed
			pulling -= 1
		
		if Input.is_action_pressed("primary_action"):
			total += progress_speed
			if pulling > 0:
				tension += tension_speed
		else:
			total -= release_speed
		
		progress += total
		tension += tension_slow
	
	tension = clamp(tension, 0, 100.0)
	progress = clamp(progress, 0, 100.0)
	
	if progress >= 100.0:
		_reached_end(true)
	if tension >= 100.0:
		_reached_end(false)
	
	
	$"%fish".rect_rotation = turn * 180.0
	$"%fish".rect_position.y = - 46 + (492 * (progress * 0.01))
	$"%tension".value = tension
	$"%progress".value = progress
	$"%reel".play("default", total < 0)

func _reached_end(win):
	$Control2 / Panel2 / .show()
	if win: $Control2 / Panel2 / TextureRect.texture = preload("res://Assets/Textures/UI/winmsg1.png")
	else: $Control2 / Panel2 / TextureRect.texture = preload("res://Assets/Textures/UI/winmsg2.png")
	active = false
	yield(get_tree().create_timer(1.0), "timeout")
	_end(win)
