extends Control
class_name GenericUIButton

func _ready():
	connect("mouse_entered", GlobalAudio, "_play_sound", ["swish"])
	if has_signal("button_down"): connect("button_down", GlobalAudio, "_play_sound", ["button_down"])
	if has_signal("button_up"): connect("button_up", GlobalAudio, "_play_sound", ["button_up"])
