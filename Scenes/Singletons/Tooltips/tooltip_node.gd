@icon("res://Assets/Textures/UI/bait_icons2.png")
extends Control
class_name TooltipNode

@export var header = "!no_text!"
@export var body = "!no_text!" # (String, MULTILINE)
@export var inspect_body = ""

var node

signal _entered
signal _exit

func _ready():
	mouse_filter = Control.MOUSE_FILTER_PASS
	connect("mouse_entered", Callable(Tooltip, "_hover_enter").bind(self))
	connect("mouse_entered", Callable(self, "emit_signal").bind("_entered"))
	connect("mouse_exited", Callable(Tooltip, "_hover_exit").bind(self))
	connect("mouse_exited", Callable(self, "emit_signal").bind("_exit"))

func _disable():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	disconnect("mouse_entered", Callable(Tooltip, "_hover_enter"))
	disconnect("mouse_exited", Callable(Tooltip, "_hover_exit"))

func _reset():
	header = "!no_text!"
	body = "!no_text!"
	inspect_body = ""
