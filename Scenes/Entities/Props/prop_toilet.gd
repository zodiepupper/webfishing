extends PlayerProp

func _ready():
	custom_valid_actions = ["_flush"]

func _sync_flush():
	_flush()
	Network._send_actor_action(actor_id, "_flush", [], false)

func _flush():
	$AudioStreamPlayer3D.play()
