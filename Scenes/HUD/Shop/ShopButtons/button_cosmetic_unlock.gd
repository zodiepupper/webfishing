extends ShopButton

export var cosmetic_unlock = ""

func _setup():
	var data = Globals.cosmetic_data[cosmetic_unlock]["file"]
	icon = null
	mod_icon.texture = data.icon
	mod_icon.modulate = data.main_color * 0.9
	slot_name = data.name
	slot_desc = data.desc + "\n[color=#6a4420]" + str(data.category) + "[/color]"
	
	if loan_level_require > PlayerData.loan_level:
		mod_icon.texture = null

func _custom_update():
	if PlayerData.cosmetics_unlocked.has(cosmetic_unlock): owned = true

func _custom_purchase():
	PlayerData._unlock_cosmetic(cosmetic_unlock)
