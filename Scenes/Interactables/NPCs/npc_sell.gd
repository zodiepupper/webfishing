extends Interactable

func _activate(actor):
	actor.hud._request_item_choice()
	var items = yield(actor.hud, "_items_chosen")
	print("chosen items: ", items)
	
	for item in items:
		PlayerData.money += PlayerData._get_item_worth(item)
		PlayerData._remove_item(item)
