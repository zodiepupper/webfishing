extends Control

var dial_max = 12

var moving_min = false
var moving_max = false

var min_set = 0
var max_set = 12

onready var dials = $dials
onready var min_dial = $dials / min_players
onready var max_dial = $dials / max_players

onready var min_dial_lbl = $dials / min_players / Label
onready var max_dial_lbl = $dials / max_players / Label

signal _update(_min, _max)

func _ready():
	min_set = 0.0
	_set_dial_pos(min_dial)
	max_set = float(dial_max - 1)
	_set_dial_pos(max_dial)

func _physics_process(delta):
	var max_size = rect_size.x
	min_dial.rect_position.x = lerp(min_dial.rect_position.x, (max_size / dial_max) * min_set, 0.8)
	min_dial.rect_scale = lerp(min_dial.rect_scale, Vector2.ONE if not moving_min else Vector2(1.1, 1.1), 0.8)
	max_dial.rect_position.x = lerp(max_dial.rect_position.x, (max_size / dial_max) * max_set, 0.8)
	max_dial.rect_scale = lerp(max_dial.rect_scale, Vector2.ONE if not moving_max else Vector2(1.1, 1.1), 0.8)
	
	if not moving_min and not moving_max: return
	
	var pos = rect_global_position.x
	var mouse = get_global_mouse_position().x
	
	var final_pos = (mouse - pos) / max_size
	var percent_index = clamp(floor(final_pos / (1.0 / dial_max)), 0, dial_max - 1)
	
	if moving_min:
		if min_set != percent_index:
			min_set = percent_index
			_set_dial_pos(min_dial)
		
		if min_set >= max_set:
			max_set = min_set
			moving_max = true
			moving_min = false
	
	elif moving_max:
		if max_set != percent_index:
			max_set = percent_index
			_set_dial_pos(max_dial)
		
		if max_set < min_set:
			min_set = max_set
			moving_min = true
			moving_max = false
	
	if not Input.is_mouse_button_pressed(BUTTON_LEFT):
		moving_min = false
		moving_max = false
		emit_signal("_update", min_set, max_set)

func _set_dial_pos(dial):
	dial.rect_pivot_offset = dial.rect_size / 2.0
	dial.rect_scale = Vector2(0.6, 0.6)
	
	min_dial_lbl.text = str(min_set + 1)
	max_dial_lbl.text = str(max_set + 1)
	if max_set == (dial_max - 1): max_dial_lbl.text = "ANY"
	$lbl.text = min_dial_lbl.text + " - " + max_dial_lbl.text + " Players"
	
	$bar.anchor_left = (min_set / dial_max) + 0.05
	$bar.anchor_right = (max_set / dial_max) + 0.05

func _on_min_players_button_down():
	moving_min = true
	moving_max = false

func _on_max_players_button_down():
	moving_min = false
	moving_max = true
