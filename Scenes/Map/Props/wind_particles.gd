extends Node3D

var amt = 0.0

func _ready():
	var roll = randi() % 2
	get_child(roll).visible = true

func _physics_process(delta):
	amt += 0.24
	$Plane.get_surface_override_material(0).set_shader_parameter("scroll_amt", amt)
	if amt > 35: queue_free()
