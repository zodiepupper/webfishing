extends ShopButton

export var bait_add = ""

func _setup():
	icon = PlayerData.BAIT_DATA[bait_add].icon
	slot_name = PlayerData.BAIT_DATA[bait_add].name + " License"
	slot_desc = "Unlocks the " + PlayerData.BAIT_DATA[bait_add].name + " bait type."

func _custom_update():
	if PlayerData.bait_unlocked.has(bait_add): owned = true

func _custom_purchase():
	PlayerData.bait_unlocked.append(bait_add)
	PlayerData._refill_bait(bait_add, false)
	PlayerData.emit_signal("_bait_update")
	PlayerData._send_notification(PlayerData.BAIT_DATA[bait_add].name + " bait unlocked")
