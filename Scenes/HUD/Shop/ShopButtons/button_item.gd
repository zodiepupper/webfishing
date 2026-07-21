extends ShopButton

export var item_id = ""
export var item_no_duplicates = false
export var max_item_owned = - 1

func _setup():
	var data = Globals.item_data[item_id]["file"]
	icon = data.icon
	slot_name = data.item_name
	slot_desc = data.item_description

func _custom_update():
	var count = 0
	if item_no_duplicates or max_item_owned != - 1:
		var valid = true
		for item in PlayerData.inventory:
			if item["id"] == item_id:
				valid = false
				count += 1
		if not valid and item_no_duplicates: owned = true
	
	if max_item_owned != - 1 and count >= max_item_owned:
		owned = true

func _custom_purchase():
	PlayerData._send_notification(slot_name + " obtained!")
	PlayerData._add_item(item_id)
