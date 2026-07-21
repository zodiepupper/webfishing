extends Control

var open = false
var pressed = false
var hovered = null

onready var wheel = $wheel

signal _play_emote(emote_id, emotion)

func _ready():
	hovered = null
	var i = 0
	for child in $wheel / GridContainer.get_children():
		if child.is_in_group("emote_ignore"): continue
		child.connect("mouse_entered", self, "_highlight", [child])
		child.connect("mouse_exited", self, "_dehighlight", [child])
		child.connect("pressed", self, "_pressed", [child])
		
		i += 1

func _open():
	
	open = true
	pressed = false

func _close():
	if not open: return
	open = false
	if hovered and not pressed: hovered.emit_signal("pressed")

func _pressed(child):
	pressed = true
	emit_signal("_play_emote", child.emote_id, child.emotion)

func _physics_process(delta):
	modulate.a = lerp(modulate.a, float(open), 0.4)
	visible = modulate.a > 0.02
	
	var scale = 1.0 if open else 0.6
	wheel.rect_scale.x = lerp(wheel.rect_scale.x, scale, 0.4)
	wheel.rect_scale.y = lerp(wheel.rect_scale.y, scale, 0.4)

func _highlight(button):
	hovered = button
	for child in $wheel / GridContainer.get_children():
		if child.is_in_group("emote_ignore"): continue
		child._highlight(child == button)

func _dehighlight(button):
	if hovered == button: hovered = null
	for child in $wheel / GridContainer.get_children():
		if child.is_in_group("emote_ignore"): continue
		child._highlight(false)

func _on_Button_pressed():
	pressed = true
	emit_signal("_play_emote", "", "")
