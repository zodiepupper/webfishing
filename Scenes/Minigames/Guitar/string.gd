extends Control

export var height = 0.0
export var height_bot = 1.0

var inside = false
var old_mouse_pos = Vector2.INF
var step_size = 2
var wobble = 0.0

signal _pluck(vol)

func _ready():
	$VBoxContainer.anchor_top = height
	$VBoxContainer.anchor_bottom = height_bot
	$VBoxContainer / string_1.material = preload("res://Assets/Shaders/guitar_string.tres").duplicate()
	$VBoxContainer / string_2.material = preload("res://Assets/Shaders/guitar_string.tres").duplicate()
	

func _process(delta):
	var local_mouse_pos = get_local_mouse_position()
	var dir = (local_mouse_pos - old_mouse_pos).normalized()
	var _inside = false
	var mouse_distance = 0.0
	
	if old_mouse_pos != Vector2.INF:
		for step in floor((local_mouse_pos - old_mouse_pos).length() / step_size) + 1:
			var new_pos = old_mouse_pos + (dir * (step * step_size))
			var rect_check = Rect2(Vector2(0, 0), get_global_rect().size)
			if rect_check.has_point(new_pos):
				_inside = true
				mouse_distance = clamp(stepify(abs(rect_check.get_center().y - new_pos.y) / 200.0, 0.01), 0.0, 0.9)
		
		if _inside and Input.is_action_pressed("primary_action"):
			if not inside:
				emit_signal("_pluck", mouse_distance)
			inside = true
		else:
			inside = false
	
	old_mouse_pos = get_local_mouse_position()

func _physics_process(delta):
	var stretch = sin(OS.get_ticks_msec() * 0.08) * wobble
	wobble = lerp(wobble, 0.0, 0.12)
	
	$VBoxContainer / string_1.material.set_shader_param("stretch", stretch)
	$VBoxContainer / string_2.material.set_shader_param("stretch", stretch)
