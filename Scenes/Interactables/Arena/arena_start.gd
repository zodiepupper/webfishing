extends Interactable

func _activate(actor):
	if Network.GAME_MASTER:
		PlayerData.emit_signal("_request_arena_start")
		
