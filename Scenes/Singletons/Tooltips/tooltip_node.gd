extends Control
class_name TooltipNode, "res://Assets/Textures/UI/bait_icons2.png"

export var header = "!no_text!"
export (String, MULTILINE) var body = "!no_text!"
export var inspect_body = ""

var node

signal _entered
signal _exit

func _ready():
	mouse_filter = Control.MOUSE_FILTER_PASS
	connect("mouse_entered", Tooltip, "_hover_enter", [self])
	connect("mouse_entered", self, "emit_signal", ["_entered"])
	connect("mouse_exited", Tooltip, "_hover_exit", [self])
	connect("mouse_exited", self, "emit_signal", ["_exit"])

func _disable():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	disconnect("mouse_entered", Tooltip, "_hover_enter")
	disconnect("mouse_exited", Tooltip, "_hover_exit")

func _reset():
	header = "!no_text!"
	body = "!no_text!"
	inspect_body = ""
