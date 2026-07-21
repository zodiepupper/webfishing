extends Interactable

func _activate(actor):
	if PlayerData.saved_aqua_fish.id != "empty":
		PlayerData._add_raw_item(PlayerData.saved_aqua_fish)
		PlayerData._aquarium_update({"id": "empty", "size": 1.0, "ref": 0, "quality": PlayerData.ITEM_QUALITIES.NORMAL}, false)
		PlayerData._send_notification("fish retrieved from aquarium", 0)
		return
	
	var item = actor.held_item
	if Globals.item_data[item["id"]]["file"].category != "fish":
		PlayerData._send_notification("held object is NOT a valid fish!", 1)
		return
	
	actor._equip_item({"ref": 0}, true, true)
	PlayerData._aquarium_update(item, true)
