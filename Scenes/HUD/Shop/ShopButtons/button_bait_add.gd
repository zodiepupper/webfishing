extends ShopButton

export var bait_add = ""

func _setup():
	icon = PlayerData.BAIT_DATA[bait_add].icon
	slot_name = PlayerData.BAIT_DATA[bait_add].name + " Bait Restock"
	slot_desc = "refills " + PlayerData.BAIT_DATA[bait_add].name + " bait."
	

func _custom_update():
	var main_cost = PlayerData.BAIT_DATA[bait_add].cost
	var percent_filled = 1.0 - (float(PlayerData.bait_inv[bait_add]) / float(PlayerData.max_bait))
	cost = ceil(main_cost * percent_filled)
	if not PlayerData.bait_unlocked.has(bait_add): locked = true

func _custom_purchase():
	PlayerData._refill_bait(bait_add)
	PlayerData.emit_signal("_bait_update")
