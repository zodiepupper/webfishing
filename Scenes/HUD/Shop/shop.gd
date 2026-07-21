extends Control

const SETUPS = {
	"test_shop": preload("res://Scenes/HUD/Shop/ShopSetups/test_shop.tscn"), 
	"progression_shop": preload("res://Scenes/HUD/Shop/ShopSetups/progression_shop.tscn"), 
	"bait_shop": preload("res://Scenes/HUD/Shop/ShopSetups/bait_shop.tscn"), 
	"general_shop": preload("res://Scenes/HUD/Shop/ShopSetups/general_shop.tscn"), 
	"sell": preload("res://Scenes/HUD/Shop/ShopSetups/sell_shop.tscn"), 
	"sell_alt": preload("res://Scenes/HUD/Shop/ShopSetups/sell_shop_tiny.tscn"), 
	"quest_board": preload("res://Scenes/HUD/Shop/ShopSetups/quest_board.tscn"), 
	"vending": preload("res://Scenes/HUD/Shop/ShopSetups/vending_shop.tscn"), 
	"spectral": preload("res://Scenes/HUD/Shop/ShopSetups/spectral_shop.tscn"), 
	"boat": preload("res://Scenes/HUD/Shop/ShopSetups/boat_shop.tscn"), 
}

export (NodePath) var hud

var cash_lerp = 0
var shown = false
var shop_type = ""
var rotated_shop = false
var quest_board = false
var refresh_type = 0
var main_setup = null
var dialogue_voice = null

onready var category_holder = $"%VBoxContainer"
onready var cash = $Panel2 / HBoxContainer / cash
onready var timer = $Panel2 / HBoxContainer / timer
onready var dialogue_box = $dialogue / RichTextLabel

func _ready():
	PlayerData.connect("_shop_refresh", self, "_force_refresh")
	PlayerData.connect("_quest_update", self, "_force_quest_refresh")
	PlayerData.connect("_upgrade_update", self, "_upgrade_refresh")
	PlayerData.connect("_float_number", self, "_float_number")

func _open(id):
	shown = true
	modulate.a = 0.0
	_setup_shop(id)
	GlobalAudio._play_sound("shop_enter")

func _close():
	if shown: GlobalAudio._play_sound("shop_exit")
	shown = false

func _process(delta):
	var time_left = OS.get_time(true)
	timer.text = str(time_left)
	
	modulate.a = lerp(modulate.a, float(shown), 0.2)
	visible = modulate.a > 0.02
	
	cash_lerp = lerp(cash_lerp, PlayerData.money, 0.2)
	var cash = (str(round(cash_lerp))).pad_zeros(9)
	cash = cash.insert(cash.length() - str(PlayerData.money).length(), "[color=#ffeed5]")
	$Panel2 / HBoxContainer2 / cash / Label.bbcode_text = "[right][color=#ffeed5]$ [color=#d5aa73]" + cash
	
	var mod = 0.6 + (sin(OS.get_ticks_msec() * 0.005) * 0.4)
	$scroll_down.self_modulate.a = mod
	$scroll_up.self_modulate.a = mod
	
	var scrollV_max = max(0, $"%HBoxContainer".rect_size.y - $"%ScrollContainer".rect_size.y)
	var scroll = $"%ScrollContainer".scroll_vertical
	$scroll_down.visible = scroll < scrollV_max
	$scroll_up.visible = scroll > 0

func _setup_shop(id):
	print("Setting Up Shop w ID ", id)
	
	
	$Panel5 / item_display.texture = null
	$"%bplabel".text = "shop"
	category_holder.visible = true
	shop_type = id
	
	for child in category_holder.get_children():
		child.queue_free()
	
	if is_instance_valid(main_setup):
		main_setup.queue_free()
		main_setup = null
	
	
	var setup = SETUPS[id].instance()
	add_child(setup)
	
	main_setup = setup
	dialogue_voice = null
	
	if setup.dialogue:
		$dialogue.visible = true
		dialogue_voice = setup.dialogue_voice
		_set_dialogue(setup.dialogue_open[randi() % setup.dialogue_open.size()])
	else: $dialogue.visible = false
	
	refresh_type = setup.refresh_type
	$"%bplabel".text = setup.shop_title
	
	for child in setup.get_children():
		_add_category(child)

func _add_category(node):
	
	
	var tex = $category_template / sep.duplicate()
	category_holder.add_child(tex)
	
	
	if not node.collapse:
		var lbl = $category_template / sublabel.duplicate()
		
		if node.include_sell_all:
			var hbox = preload("res://Scenes/HUD/Shop/sell_all_button.tscn").instance()
			hbox.add_child(lbl)
			hbox.move_child(lbl, 0)
			hbox.connect("_sell_all", self, "_sell_all")
			category_holder.add_child(hbox)
		else:
			category_holder.add_child(lbl)
		
		lbl.text = node.category_title
		if node.loan_level_lock > PlayerData.loan_level:
			lbl.text = "LOCKED"
	
	
	var grid
	match node.box_type:
		0: grid = $category_template / GridContainer.duplicate()
		1: grid = $category_template / questcont.duplicate()
		2: grid = $category_template / GridContainerSmall.duplicate()
		3:
			grid = $category_template / sellContainer.duplicate()
			grid.shop_main = self
			grid._refresh()
	
	
	if node.collapse:
		var coll = $category_template / collapse.duplicate()
		coll._setup(node.category_title)
		category_holder.add_child(coll)
		coll.collapse_node = grid
		coll._refresh()
	
	
	category_holder.add_child(grid)
	
	
	match node.replace:
		0:
			for child in node.get_children():
				node.remove_child(child)
				grid.add_child(child)
				child.hud = get_node(hud)
				child.connect("mouse_entered", self, "_item_entered", [child])
				child.connect("_used", self, "_slot_used")
		
		1:
			for item in PlayerData.current_shop:
				var button = preload("res://Scenes/HUD/Shop/ShopButtons/shop_button.tscn").instance()
				button.set_script(preload("res://Scenes/HUD/Shop/ShopButtons/button_cosmetic_unlock.gd"))
				button.cosmetic_unlock = item
				button.cost = Globals.cosmetic_data[item]["file"].cost
				grid.add_child(button)
				button.hud = get_node(hud)
				button.connect("mouse_entered", self, "_item_entered", [button])
				button.connect("_used", self, "_slot_used")
		
		2:
			print("Sell Setup")
		
		3:
			var alt = false
			
			var final_order = []
			for quest in PlayerData.current_quests.keys():
				var data = PlayerData.current_quests[quest]
				if data.progress >= data.goal_amt: final_order.append(quest)
			for quest in PlayerData.current_quests.keys():
				var data = PlayerData.current_quests[quest]
				if data.progress < data.goal_amt: final_order.append(quest)
			
			for quest in final_order:
				var data = PlayerData.current_quests[quest]
				var button = preload("res://Scenes/HUD/Shop/quest_button.tscn").instance()
				button._setup(quest, alt)
				button.connect("pressed", self, "_quest_pressed", [quest])
				grid.add_child(button)
				alt = not alt
		
		4:
			for bait in PlayerData.bait_unlocked:
				if bait == "": continue
				var button = preload("res://Scenes/HUD/Shop/ShopButtons/shop_button.tscn").instance()
				button.set_script(preload("res://Scenes/HUD/Shop/ShopButtons/button_bait_add.gd"))
				button.bait_add = bait
				
				grid.add_child(button)
				button.hud = get_node(hud)
				button.connect("mouse_entered", self, "_item_entered", [button])
				button.connect("_used", self, "_slot_used")
	
	
	var sep = $category_template / HSeparator.duplicate()
	category_holder.add_child(sep)
	sep = $category_template / HSeparator.duplicate()
	category_holder.add_child(sep)

func _item_entered(node):
	$Panel5 / item_display._setup_nonitem(node.icon)
	$Panel3 / header.bbcode_text = str(node.slot_name)
	$Panel3 / body.bbcode_text = str(node.slot_desc)





func _force_refresh(): if shown: _setup_shop(shop_type)
func _force_quest_refresh(): if shown: _setup_shop(shop_type)





func _quest_pressed(quest):
	PlayerData._complete_quest(quest)

func _on_Button_pressed():
	PlayerData.emit_signal("_force_menu_close")





func _float_number(text, color, dir, pos):
	var fn = preload("res://Scenes/HUD/Shop/FloatNumber/float_number.tscn").instance()
	add_child(fn)
	fn.global_position = pos
	fn._setup(text, color, dir)





func _slot_used():
	if main_setup.dialogue: _set_dialogue(main_setup.dialogue_buy[randi() % main_setup.dialogue_buy.size()])

func _set_dialogue(text):
	dialogue_box.visible_characters = 0
	dialogue_box.bbcode_text = text

func _dialogue_update():
	dialogue_box.visible_characters += 1
	if dialogue_box.visible_characters <= dialogue_box.bbcode_text.length() and dialogue_voice:
		var letter = dialogue_box.bbcode_text[dialogue_box.visible_characters - 1]
		if letter == "" or letter == "." or letter == " " or letter == ",": return
		
		var audio = AudioStreamPlayer.new()
		add_child(audio)
		audio.stream = dialogue_voice
		audio.connect("finished", audio, "queue_free")
		audio.play()





func _sell_all():
	var valid_items = []
	var total_cost = 0
	
	for item in PlayerData.inventory:
		var file = Globals.item_data[item["id"]]["file"]
		if file.unselectable or not file.can_be_sold or PlayerData.locked_refs.has(item["ref"]): continue
		
		var item_worth = PlayerData._get_item_worth(item["ref"])
		
		valid_items.append(item["ref"])
		total_cost += item_worth
	
	for ref in valid_items:
		PlayerData._remove_item(ref, true, false)
	PlayerData.money += total_cost
	
	PlayerData._send_notification("sold all " + str(valid_items.size()) + " item(s) for $" + str(total_cost))
	PlayerData.emit_signal("_inventory_refresh")
	PlayerData.emit_signal("_hotbar_refresh")
	
	_force_refresh()
