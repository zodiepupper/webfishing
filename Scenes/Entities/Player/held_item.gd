extends Sprite3D

var vel = 0.0
var angl = 0.0
var grav = 15.0
var cd = 0
var offs = 0.0

var mult = 1.0

func _physics_process(delta):
	vel -= grav * delta * mult
	translation.x += vel * delta
	translation.x = clamp(translation.x, 0.0, 0.5)
	rotation_degrees.y = lerp(rotation_degrees.y, angl * 25.0 * pow(translation.x, 2.5), 0.7)
	
	cd -= 1
	if cd <= 0 and translation.x < 0.3:
		cd = rand_range(20, 130)
		vel = rand_range(1.0, 2.6) * mult
		angl = rand_range( - 24, 24)
