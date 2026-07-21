extends Interactable

var mode = 0

signal _activated

func _activate(actor):
	if not actor.controlled: return
	emit_signal("_activated")
