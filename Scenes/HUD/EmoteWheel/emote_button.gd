extends Control

export var emote_id = ""
export var emotion = ""
export (Texture) var emote_icon

var des_scale = 1.0

signal pressed

func _ready():
	_highlight(false)
	$TextureRect.texture = emote_icon
	




func _highlight(selected):
	var color = Color(1.0, 1.0, 1.0) if selected else Color("baa07f")
	des_scale = 1.04 if selected else 1.0
	
	modulate = color

func _physics_process(delta):
	rect_pivot_offset = rect_size / 2.0
	rect_scale = lerp(rect_scale, Vector2(des_scale, des_scale), 0.2)

func _on_Button_pressed():
	emit_signal("pressed")
