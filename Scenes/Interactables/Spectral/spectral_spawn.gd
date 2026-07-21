extends Interactable

export var item_id = ""

func _activate(actor):
	for item in PlayerData.inventory:
		if item.id == item_id:
			PlayerData._send_notification("already carrying this bone...", 1)
			return
	
	PlayerData._send_notification("collected a spectral bone...", 0)
	var ref = PlayerData._add_item(item_id, - 1, 10)
	actor._obtain_item(ref)
	
	if not PlayerData.saved_tags.has("spectral"):
		yield(get_tree().create_timer(5.0), "timeout")
		PlayerData.saved_tags.append("spectral")
		PlayerData._send_notification("you feel an otherworldly force beckon you...")
		Network._update_chat("[color=#008583]" + "you feel an otherworldly force beckon you..." + "[/color]")
