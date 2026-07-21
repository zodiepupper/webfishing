extends ShopButton

export var max_add = 0
export var max_req = 0

func _custom_update():
	if PlayerData.max_bait < max_req: locked = true
	if PlayerData.max_bait > max_req: owned = true

func _custom_purchase():
	PlayerData.max_bait = max_add
	PlayerData._send_notification("Max Bait Increased!")
	PlayerData._refill_bait("")
