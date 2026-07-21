extends ShopButton

var item_id = ""
var linked_ref = - 1

signal _sold

func _setup():
	cost_type = "none"
	purchase_text = "sold!"
	
	var data = Globals.item_data[item_id]["file"]
	icon = data.icon
	slot_name = PlayerData._get_item_name(linked_ref)
	slot_desc = data.item_description








func _custom_purchase():
	PlayerData.money += PlayerData._get_item_worth(linked_ref)
	PlayerData.emit_signal("_item_sold", linked_ref)
	PlayerData._remove_item(linked_ref, true, false)
	emit_signal("_sold")
