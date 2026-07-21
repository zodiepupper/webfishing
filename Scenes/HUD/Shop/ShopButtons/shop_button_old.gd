extends Button

export var item_id = ""
export var cosmetic_unlock = ""
export var bait_add = ""
export var bait_unlock = ""
export var custom_unlock = ""
export var upgrade_slot = - 1

export var money_cost = 0
export (String, "money", "credits") var money_type = "money"
export (Array, String) var item_require

var hud
var slot_name = ""
var slot_desc = ""

var is_selling = false
var linked_ref = - 1

export var item_no_duplicates = false

func _ready():
	if item_id != "":
		var data = Globals.item_data[item_id]["file"]
		icon = data.icon
		slot_name = data.item_name
		slot_desc = data.item_description
	
	if cosmetic_unlock != "":
		var data = Globals.cosmetic_data[cosmetic_unlock]["file"]
		icon = data.icon
		slot_name = data.name
		slot_desc = data.desc
	
	if bait_add != "":
		icon = PlayerData.BAIT_ICONS[bait_add]
	
	if upgrade_slot != - 1:
		var upgrade = PlayerData.shop_upgrades[upgrade_slot]
		var data = Globals.upgrade_data[upgrade]["file"]
		icon = data.upgrade_icon
		slot_name = data.upgrade_name
		slot_desc = data.upgrade_desc
	
	$TooltipNode.header = slot_name
	$TooltipNode.body = slot_desc
	PlayerData.connect("_shop_update", self, "_update")
	_update()

func _update():
	var owned = false
	
	if cosmetic_unlock != "" and PlayerData.cosmetics_unlocked.has(cosmetic_unlock): owned = true
	if bait_unlock != "" and bait_add == "" and PlayerData.bait_unlocked.has(bait_unlock): owned = true
	
	disabled = owned
	$Panel2.visible = owned
	
	if item_id != "" and item_no_duplicates:
		var valid = true
		for item in PlayerData.inventory:
			if item["id"] == item_id:
				valid = false
				break
		if not valid:
			disabled = true
			$Panel2.visible = true
	
	if is_selling:
		var has = false
		for item in PlayerData.inventory:
			if item["ref"] == linked_ref:
				has = true
		if not has: queue_free()
	
	var prefix = ""
	var owned_money = 0
	match money_type:
		"money":
			prefix = "$"
			owned_money = PlayerData.money
		"credits":
			prefix = "c"
			owned_money = PlayerData.fishcredits
	
	match custom_unlock:
		"stamina":
			money_cost = ceil((PlayerData.max_stamina * PlayerData.max_stamina) / 8.0)
		"upgrade":
			money_cost = ceil((PlayerData.upgrades.size() * PlayerData.upgrades.size()) / 8.0)
	
	if money_cost > 0 and owned_money < money_cost and not is_selling: disabled = true
	if bait_add != "" and not PlayerData.bait_unlocked.has(bait_unlock): disabled = true
	if bait_add != "" and bait_unlock != "" and PlayerData.bait_unlocked.has(bait_unlock): disabled = true
	
	$Panel / Label.text = prefix + str(money_cost)

func _on_shop_button_pressed():
	if item_require != []:
		var items_left = item_require.duplicate()
		
		hud._request_item_choice(item_require, item_require.size(), item_require.size())
		var items = yield(hud, "_items_chosen")
		print("chosen items: ", items)
		
		for item in items:
			var data = PlayerData._find_item_code(item)
			var slot = items_left.find(data["id"])
			if slot != - 1: items_left.remove(slot)
		
		print("Item required left: ", items_left)
		if not items_left.empty(): return
		
		for item in items:
			PlayerData._remove_item(item)
	
	if cosmetic_unlock != "": PlayerData._unlock_cosmetic(cosmetic_unlock)
	
	if bait_unlock != "":
		PlayerData.bait_unlocked.append(bait_unlock)
		PlayerData.emit_signal("_bait_update")
	elif bait_add != "":
		PlayerData.bait_inv[bait_add] += 1
		PlayerData.emit_signal("_bait_update")
	
	if item_id != "":
		if not is_selling:
			PlayerData._add_item(item_id)
		
		else:
			PlayerData.money += PlayerData._get_item_worth(linked_ref)
			PlayerData.fishcredits += PlayerData._get_item_worth(linked_ref, "credits")
			PlayerData._remove_item(linked_ref)
	
	match custom_unlock:
		"stamina":
			PlayerData.max_stamina += 2
		"upgrade":
			PlayerData._add_upgrade(PlayerData.shop_upgrades[upgrade_slot])
	
	if not is_selling:
		match money_type:
			"money": PlayerData.money -= money_cost
			"credits": PlayerData.fishcredits -= money_cost
	
	PlayerData.emit_signal("_shop_update")
