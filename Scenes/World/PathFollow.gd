extends PathFollow

var reset = false
var speed = 0.08
var des_speed = 0.0
var real_speed = 0.0

func _physics_process(delta):
	
	
	if not reset:
		des_speed = speed
		if offset > 110: reset = true
	else:
		des_speed = - speed
		if offset < 15: reset = false
	
	real_speed = lerp(real_speed, des_speed, 0.05)
	offset += real_speed
