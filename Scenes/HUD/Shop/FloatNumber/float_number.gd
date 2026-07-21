extends Node2D

var speed = 0.0
var lifetime = 70

func _setup(text, color, dir):
	$Label.set("custom_colors/font_color", Color(color))
	$Label.text = text
	
	speed = dir

func _physics_process(delta):
	global_position.y += speed
	lifetime -= 1
	if lifetime <= 0: queue_free()
