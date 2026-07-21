extends ShopButton

export var upgrade_slot = 0

func _setup():
	var upgrade = PlayerData.shop_upgrades[upgrade_slot]
	var data = Globals.upgrade_data[upgrade]["file"]
	icon = data.upgrade_icon
	slot_name = data.upgrade_name
	slot_desc = data.upgrade_desc

func _custom_update():
	cost = ceil((PlayerData.upgrades.size() * PlayerData.upgrades.size()) / 8.0)

func _custom_purchase():
	PlayerData._add_upgrade(PlayerData.shop_upgrades[upgrade_slot])
