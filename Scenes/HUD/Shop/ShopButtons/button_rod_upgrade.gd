extends ShopButton

enum TYPE{POWER, SPEED, CHANCE, BAITMAX, BUDDY, BUDDY_SPEED, LUCK}

export (TYPE) var type = TYPE.POWER

func _custom_update():
	var value = [PlayerData.rod_power_level, PlayerData.rod_speed_level, PlayerData.rod_chance_level, floor(PlayerData.max_bait / 5.0) - 1, PlayerData.buddy_level, PlayerData.buddy_speed, PlayerData.rod_luck_level][type]
	var new_cost = [100, 350, 1000, 5000, 10000, 12500, 17500, 25000, 30000, 40000, 50000][value]
	var max_value = 5
	
	if type == TYPE.POWER: max_value = 8
	elif type == TYPE.BAITMAX: max_value = 9
	
	var title = ["Rod Power", "Rod Speed", "Rod Chance", "Tacklebox Upgrade", "Buddy Quality Upgrade", "Buddy Speed Upgrade", "Rod Luck"][type]
	
	var desc_title = ""
	var desc_value = 0
	match type:
		TYPE.POWER:
			desc_title = "Increase Rod Power "
			desc_value = [1, 3, 10, 20, 35, 50, 70, 90, 125, 125]
		TYPE.SPEED:
			desc_title = "Increase Rod Reel Speed "
			desc_value = [0, 1, 2, 3, 4, 5, 5]
		TYPE.CHANCE:
			desc_title = "Increase Rod Catch Chance "
			desc_value = [0, 1, 2, 3, 4, 5, 5]
		TYPE.LUCK:
			desc_title = "Increase Rod Luck (Chance of catching bonus loot) "
			desc_value = [0, 1, 2, 3, 4, 5, 5]
		TYPE.BAITMAX:
			desc_title = "Increase Max Bait "
			desc_value = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 50]
		TYPE.BUDDY:
			desc_title = "Increase your Fishing Buddy's Fishing Highest Quality "
			desc_value = ["Normal", "Shining", "Glistening", "Opulent", "Radiant", "Alpha", "Alpha"]
			new_cost = ceil(new_cost * 1.5) + 200
		TYPE.BUDDY_SPEED:
			desc_title = "Increase your Fishing Buddy's Catch Speed "
			desc_value = [1, 2, 3, 4, 5, 6, 6]
			new_cost = ceil(new_cost * 1.5) + 150
	
	slot_name = title + " " + str(value + 1)
	saved_desc = desc_title + "from " + str(desc_value[value]) + " > " + str(desc_value[value + 1])
	
	cost = new_cost
	
	if value >= max_value:
		slot_name = title + " MAX"
		saved_desc = desc_title + "MAXED"
		owned = true

func _custom_purchase():
	match type:
		TYPE.POWER:
			PlayerData._send_notification("Rod Power Upgraded!")
			PlayerData.rod_power_level += 1
		TYPE.SPEED:
			PlayerData._send_notification("Rod Reel Speed Upgraded!")
			PlayerData.rod_speed_level += 1
		TYPE.CHANCE:
			PlayerData._send_notification("Rod Catch Chance Upgraded!")
			PlayerData.rod_chance_level += 1
		TYPE.LUCK:
			PlayerData._send_notification("Rod Luck Upgraded!")
			PlayerData.rod_luck_level += 1
		TYPE.BAITMAX:
			PlayerData._send_notification("Max Bait Upgraded!")
			PlayerData.max_bait += 5
		TYPE.BUDDY:
			PlayerData._send_notification("Fishing Buddy Quality Upgraded!")
			PlayerData.buddy_level += 1
		TYPE.BUDDY_SPEED:
			PlayerData._send_notification("Fishing Buddy Speed Upgraded!")
			PlayerData.buddy_speed += 1
	PlayerData.emit_signal("_bait_update")
