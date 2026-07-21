extends ShopButton

export var lure_add = ""

func _setup():
	slot_name = PlayerData.LURE_DATA[lure_add].name
	icon = PlayerData.LURE_DATA[lure_add].icon
	slot_desc = "Unlocks the " + PlayerData.LURE_DATA[lure_add].name + " lure:\n\n" + str(PlayerData.LURE_DATA[lure_add].desc)

func _custom_update():
	if PlayerData.lure_unlocked.has(lure_add): owned = true

func _custom_purchase():
	PlayerData.lure_unlocked.append(lure_add)
	PlayerData.emit_signal("_bait_update")
	PlayerData._send_notification(PlayerData.LURE_DATA[lure_add].name.to_upper() + " lure unlocked")
