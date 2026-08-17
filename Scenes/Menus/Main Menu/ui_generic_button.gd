extends Control
class_name GenericUIButton

func _ready():
	connect("mouse_entered", Callable(GlobalAudio, "_play_sound").bind("swish"))
	if has_signal("button_down"): connect("button_down", Callable(GlobalAudio, "_play_sound").bind("button_down"))
	if has_signal("button_up"): connect("button_up", Callable(GlobalAudio, "_play_sound").bind("button_up"))
