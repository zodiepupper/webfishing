extends Actor
class_name PlayerProp

@export var rotation_reset = false

func _ready():
	packet_send_cooldown = 32
	
	var tween = get_tree().create_tween()
	
	scale = Vector3(0.2, 0.2, 0.2)
	tween.tween_property(self, "scale", Vector3(1.2, 1.2, 1.2), 0.15)
	tween.tween_property(self, "scale", Vector3(1, 1, 1), 0.1)
	
	if rotation_reset: rotation = Vector3.ZERO

func _custom_kill():
	PlayerData.emit_signal("_update_props")
