extends Actor

var startled = false
var dip = false
var dir = Vector3()

var hop_vel = 0
var auto_startle = 50
var flight_kill = 180
var fly_momentum = 0.0

onready var bird = $AnimatedSprite3D

func _physics_process(delta):
	hop_vel = move_toward(hop_vel, 0.0, delta * 250.0)
	bird.offset.y = lerp(bird.offset.y, hop_vel, 0.1)
	
	if startled:
		fly_momentum = lerp(fly_momentum, 0.3, 0.05)
		bird.translation.y += fly_momentum
		bird.translation.x += fly_momentum * dir.x * 1.5
		bird.translation.x += fly_momentum * dir.z * 1.5
		
		flight_kill -= 1
		if flight_kill <= 0:
			bird.scale = lerp(bird.scale, Vector3.ZERO, 0.05)
			if bird.scale.x <= 0.1: queue_free()
	else:
		bird.scale = lerp(bird.scale, Vector3.ONE, 0.2)

func _on_hop_timer_timeout():
	if startled: return
	
	auto_startle -= 1
	if auto_startle <= 0:
		_startle()
		return
	
	var hop = randf() > 0.5
	if dip: hop = false
	
	$hop_timer.wait_time = rand_range(0.2, 4.0)
	
	if hop:
		hop_vel = 42
		if randf() < 0.4:
			bird.flip_h = not bird.flip_h
		
	elif not dip:
		$hop_timer.wait_time = rand_range(0.2, 0.5)
		dip = true
		bird.frame = 1
	else:
		dip = false
		bird.frame = 0
	
	$hop_timer.start()

func _on_Area_body_entered(body):
	if not body.is_in_group("player"): return
	_startle()

func _startle():
	if startled: return
	
	$AudioStreamPlayer3D.play()
	dir.x = rand_range( - 1.0, 1.0)
	dir.z = rand_range( - 1.0, 1.0)
	bird.frame = 2
	startled = true
	$Timer.start()

func _on_Timer_timeout():
	if bird.frame == 2: bird.frame = 3
	else: bird.frame = 2
