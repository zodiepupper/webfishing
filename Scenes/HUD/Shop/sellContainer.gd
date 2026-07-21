extends GridContainer

var shop_main

func _refresh():
	for child in get_children(): child.queue_free()
	
	var maximum_items = 16
	var index = 0
	
	var new_order = []
	for item in PlayerData.inventory:
		var item_worth = PlayerData._get_item_worth(item["ref"])
		
		var file = Globals.item_data[item["id"]]["file"]
		if file.unselectable or not file.can_be_sold or PlayerData.locked_refs.has(item["ref"]): continue
		
		var i = 0
		var added = false
		for worth in new_order:
			if item_worth > worth[1]:
				new_order.insert(i, [item, item_worth])
				added = true
				break
			i += 1
		
		if not added: new_order.append([item, item_worth])
	
	for entry in new_order:
		var item = entry[0]
		
		var button = preload("res://Scenes/HUD/Shop/ShopButtons/shop_button.tscn").instance()
		button.set_script(preload("res://Scenes/HUD/Shop/ShopButtons/button_sell.gd"))
		button.item_id = item["id"]
		button.linked_ref = item["ref"]
		button.cost = PlayerData._get_item_worth(item["ref"])
		add_child(button)
		button.hud = get_node(shop_main.hud)
		button.connect("mouse_entered", shop_main, "_item_entered", [button])
		button.connect("_used", shop_main, "_slot_used")
		button.connect("_sold", self, "_refresh")
		
		index += 1
		if index > 14:
			var remaining = new_order.size() - index
			if remaining > 0:
				var lbl = preload("res://Scenes/HUD/Shop/ShopButtons/more_icon.tscn").instance()
				lbl.rect_min_size = Vector2(92, 92)
				lbl.text = "and " + str(remaining) + " more..."
				add_child(lbl)
			break
