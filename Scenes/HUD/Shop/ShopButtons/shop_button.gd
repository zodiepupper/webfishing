extends Button
class_name ShopButton

export (String, "money", "credits", "none") var cost_type = "money"
export var cost = 0
export (Array, String) var item_require
export var level_require = - 1
export var loan_level_require = - 1
export var hide_on_loan_lock = true
export var creature_require = ""
export var creature_require_amount = 0
export var custom_warning = ""
export var tag_require = ""
export var tag_warning = ""

var hud

export var slot_name = ""
export var slot_desc = ""
var saved_desc = ""
var owned = false
var locked = false
var purchase_text = "purchased!"

onready var tooltip = $TooltipNode
onready var price_label = $Label
onready var unlocked = $unlocked
onready var mod_icon = $mod_icon

signal _used

func _ready():
	_setup()
	
	tooltip.header = slot_name
	tooltip.body = slot_desc
	saved_desc = slot_desc
	PlayerData.connect("_shop_update", self, "_update")
	_update()

func _update():
	owned = false
	locked = false
	
	_custom_update()
	
	var owned_money = 0
	var prefix = ""
	var warnings = "[color=#ac0029]"
	
	match cost_type:
		"money":
			prefix = "$"
			owned_money = PlayerData.money
		"none":
			prefix = "$"
			owned_money = 99999
	
	if level_require > 0:
		if PlayerData.badge_level < level_require:
			locked = true
			warnings = warnings + ("\nRequires a Rank of " + str(level_require) + " or higher.\nCurrent Rank: ") + str(PlayerData.badge_level)
		else:
			warnings = warnings + ("\n[color=#a4aa39]Requires a Rank of " + str(level_require) + " or higher.[color=#ac0029]")
	
	if creature_require != "" and not PlayerData.DEV_CHEAT_MODE:
		var data = Globals.item_data[creature_require]["file"]
		var category = data.category
		var jcat = ""
		if category == "fish": jcat = "fish"
		elif category == "bug": jcat = "bugs"
		var amt_caught = PlayerData.journal_logs[jcat][creature_require]["count"]
		if amt_caught < creature_require_amount:
			locked = true
			warnings = warnings + "\nRequires " + str(creature_require_amount) + " " + str(data.item_name) + " to have been caught.\n" + str(data.item_name) + " Currently caught: " + str(amt_caught)
		else:
			warnings = warnings + ("\n[color=#a4aa39]Requires " + str(creature_require_amount) + " " + str(data.item_name) + " to have been caught.[color=#ac0029]")
	
	if custom_warning != "": warnings = warnings + "\n" + custom_warning
	
	if owned:
		warnings = warnings + "\nAlready Owned."
	
	if tag_require != "" and not PlayerData.saved_tags.has(tag_require):
		warnings = warnings + "\n" + tag_warning
		locked = true
	
	if cost > 0:
		if owned_money < cost:
			locked = true
			warnings = warnings + "\nCosts $" + str(cost) + ". Cannot Afford."
		else:
			warnings = warnings + "\n[color=#a4aa39]Costs $" + str(cost) + "[color=#ac0029]"
	
	price_label.text = prefix + str(cost)
	
	$lock.visible = false
	if loan_level_require > PlayerData.loan_level:
		locked = true
		$lock.visible = true
		icon = preload("res://Assets/Textures/questionmark.png")
		price_label.text = "$???"
		slot_name = "UNKNOWN"
		saved_desc = "Increase your CAMP TIER to unlock this..."
		slot_desc = "Increase your CAMP TIER to unlock this..."
		warnings = "[color=#FFFFFF]"
	
	unlocked.visible = owned
	disabled = owned or locked
	
	mod_icon.self_modulate = Color(0.6, 0.6, 0.6) if owned or locked else Color(1.0, 1.0, 1.0)
	if owned: price_label.text = prefix + "MAX"
	tooltip.header = "[color=#6a4420]" + slot_name + "[/color]"
	tooltip.body = saved_desc + warnings + "[/color]"
	slot_desc = saved_desc + warnings + "[/color]"

func _on_shop_button_pressed():
	self_modulate.a = 0.35
	
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
	
	PlayerData.emit_signal("_play_sfx", "cash" + str(randi() % 2 + 1))
	
	emit_signal("_used")
	_custom_purchase()
	
	match cost_type:
		"money": PlayerData.money -= cost
	
	PlayerData.emit_signal("_float_number", purchase_text, "#a4aa39", - 0.4, get_global_mouse_position())
	PlayerData.emit_signal("_shop_update")

func _physics_process(delta):
	self_modulate.a = lerp(self_modulate.a, 1.0, 0.06)


func _setup(): pass
func _custom_update(): pass
func _custom_purchase(): pass




































































































































