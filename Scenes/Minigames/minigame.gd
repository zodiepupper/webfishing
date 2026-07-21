extends CanvasLayer
class_name Minigame

var difficulty = 1.0
var params = {}

signal _finished(victory)

func _end(won = false):
	emit_signal("_finished", won)
	queue_free()
