extends CanvasLayer

enum MENUS{DEFAULT, BUILD, BACKPACK, ESC, BAIT, SHOP, DIALOGUE, EMOTE, UPGRADE, PROP, ARENA}

const MINIGAMES = {
	"fishing": preload("res://Scenes/Minigames/Fishing/Fishing.tscn"), 
	"fishing2": preload("res://Scenes/Minigames/Fishing2/fishing2.tscn"), 
	"fishing3": preload("res://Scenes/Minigames/Fishing3/fishing3.tscn"), 
	"shoveling": preload("res://Scenes/Minigames/Shoveling/shoveling.tscn"), 
	"painting": preload("res://Scenes/HUD/PaintingScreen/painting_screen.tscn"), 
	"guitar": preload("res://Scenes/Minigames/Guitar/guitar_minigame.tscn"), 
	"scratch_off": preload("res://Scenes/Minigames/ScratchTicket/scratch_ticket.tscn"), 
	"hand_labeler": preload("res://Scenes/Minigames/HandLabeler/hand_laber_menu.tscn"), 
}

onready var overlay = $main / in_game
onready var tab_container = $main / menu / TabContainer
onready var esc_menu = $esc_menu
onready var hotbar = $main / in_game / hotbar
onready var gamechat = $main / in_game / gamechat / RichTextLabel
onready var chat_root = $main / in_game / gamechat
onready var chat = $main / in_game / gamechat / LineEdit
onready var backpack_anim = $main / backpack / Viewport / Spatial / backpack / AnimationPlayer
onready var tacklebox_anim = $main / tacklebox / Viewport / Spatial / tacklebox / AnimationPlayer
onready var buttons = $main / menu / buttons
onready var tabs = $main / menu / tabs
onready var shop = $main / shop
onready var dialogue = $main / dialogue
onready var bait_show = $main / in_game / bait
onready var emote_wheel = $main / emote_wheel
onready var prop_menu = $main / prop_menu
onready var request_panel = $main / in_game / player_requests
onready var request_label = $main / in_game / player_requests / Label

var menu = MENUS.DEFAULT
var prev_menu = MENUS.DEFAULT
var using_chat = false
var interact = false
var popups = []
var player
var current_tab = 0
var shop_id = ""
var int_text = ""
var dialogue_text = []
var show_bait = false
var chat_timer = 0
var chat_local = false
var hud_hidden = false
var interact_timer = 0
var chat_hover = false
var chat_expand = false
var chat_hide = false
var freecamming = false
var dialogue_cooldown = 0
var recent_request = 0

signal _items_chosen
signal _minigame_finished
signal _player_sit
signal _menu_entered
signal _play_emote
signal _message_sent
signal _freecam_toggle

func _ready():
	PlayerData.connect("_hotbar_refresh", self, "_refresh_hotbar")
	PlayerData.connect("_bait_update", self, "_bait_refresh")
	PlayerData.connect("_force_menu_close", self, "_abort")
	PlayerData.connect("_request_item_choice", self, "_request_item_choice")
	
	Network.connect("_chat_update", self, "_chat_update")
	Network.connect("_new_request_from_weblobby", self, "_new_lobby_request")
	Network.connect("_weblobby_request_update", self, "_lobby_request_update")
	
	esc_menu.connect("_close", self, "_change_menu", [0])
	
	_refresh_hotbar()
	_change_tab(0)
	_change_menu(MENUS.DEFAULT)
	_toggle_chat(true)
	_lobby_request_update()
	

func _process(delta):
	var cash = (str(round(PlayerData.money))).pad_zeros(9)
	cash = cash.insert(cash.length() - str(PlayerData.money).length(), "[color=#ffeed5]")
	$main / menu / Panel4 / cashlabel.bbcode_text = "[center][color=#ffeed5]$ [color=#d5aa73]" + cash
	
	bait_show.visible = show_bait
	
	if Rect2(chat_root.rect_global_position, chat_root.rect_size).has_point(chat_root.get_global_mouse_position()) and chat_timer < 30:
		chat_timer = 30
	
	if chat_timer > 0: chat_timer -= 1
	chat_root.modulate.a = lerp(chat_root.modulate.a, max(0.4, float(chat_timer > 0 or using_chat)), 0.3)
	$main / in_game / gamechat / Panel.modulate.a = lerp($main / in_game / gamechat / Panel.modulate.a, float(chat_timer > 0 or using_chat), 0.3)
	$main / in_game / gamechat / Panel2.modulate.a = $main / in_game / gamechat / Panel.modulate.a
	gamechat.scroll_active = using_chat
	
	if popups == [] and not OptionsMenu.open:
		
		if Input.is_action_just_pressed("menu_open"):
			if hud_hidden: _show_hud()
			else:
				if menu == MENUS.DEFAULT: _change_menu(MENUS.BACKPACK)
				else: _change_menu(MENUS.DEFAULT)
		
		if Input.is_action_just_pressed("esc_menu"):
			if hud_hidden: _show_hud()
			else:
				if menu == MENUS.DEFAULT: _change_menu(MENUS.ESC)
				else: _change_menu(MENUS.DEFAULT)
		
		if Input.is_action_just_pressed("chat_enter") and menu == MENUS.DEFAULT:
			if not using_chat:
				using_chat = true
				chat.editable = true
				chat.selecting_enabled = true
				chat.focus_mode = Control.FOCUS_ALL
				chat.grab_focus()
				chat.placeholder_text = "Type to chat!"
			else:
				_send_message(chat.text)
				chat.text = ""
				_exit_chat()
		
		if not using_chat:
			if Input.is_action_just_released("bait_menu"):
				if menu == MENUS.DEFAULT: _change_menu(MENUS.BAIT)
				else: _change_menu(MENUS.DEFAULT)
			
			if Input.is_action_just_pressed("build"):
				if menu == MENUS.DEFAULT: _change_menu(MENUS.PROP)
				else: _change_menu(MENUS.PROP)
			
			if Input.is_action_just_released("emote_wheel"):
				if menu == MENUS.EMOTE: _change_menu(MENUS.DEFAULT)
			if Input.is_action_just_pressed("emote_wheel"):
				if menu == MENUS.DEFAULT: _change_menu(MENUS.EMOTE)
			
			if Input.is_action_just_pressed("interact"):
				if menu != MENUS.DEFAULT and menu != MENUS.BACKPACK:
					_change_menu(MENUS.DEFAULT)
			
			if menu == MENUS.BACKPACK:
				if Input.is_action_just_pressed("tab_next"):
					current_tab += 1
					if current_tab > 4: current_tab = 0
					_change_tab(current_tab)
				if Input.is_action_just_pressed("tab_prev"):
					current_tab -= 1
					if current_tab < 0: current_tab = 4
					_change_tab(current_tab)
			
			if Input.is_action_just_pressed("hide_hud"):
				_hide_hud()
			
			if Input.is_action_just_pressed("freecam"):
				_on_camera_pressed()
	
	if not is_instance_valid(player): queue_free()
	else:
		player.busy = menu != MENUS.DEFAULT or using_chat or popups.size() > 0
		player.show_local = using_chat and chat_local
	
	$"%new_icon".visible = PlayerData.new_cosmetics.size() > 0
	
	chat_root.anchor_top = lerp(chat_root.anchor_top, 0.66 if not chat_expand else 0.2, 0.2)
	
	chat_root.anchor_left = lerp(chat_root.anchor_left, 0.02 if not chat_hide else - 0.52, 0.2)
	chat_root.anchor_right = lerp(chat_root.anchor_right, 0.28 if not chat_hide else - 0.26, 0.2)
	$main / in_game / show_chat.visible = chat_hide
	
	$main / in_game / freecamwarning.visible = freecamming
	$main / in_game / freecamwarning.modulate.a = 0.6 + (sin(OS.get_ticks_msec() * 0.004) * 0.4)
	
	$main / in_game / player_requests.modulate.a = 0.8 + (sin(OS.get_ticks_msec() * 0.003) * 0.2)
	
	if recent_request > 0:
		recent_request -= 1
		request_label.modulate.a = 0.6 + (sin(OS.get_ticks_msec() * 0.004) * 0.4)
	else:
		request_label.modulate.a = 1.0

func _physics_process(delta):
	if interact:
		interact_timer += 2
	elif interact_timer > 0:
		if interact_timer > 28: interact_timer = 28
		interact_timer -= 2
	
	if dialogue_cooldown > 0: dialogue_cooldown -= 1
	
	var frame = floor(interact_timer / 7.0)
	if frame > 3: frame = 3 + ceil(sin(OS.get_ticks_msec() * 0.01))
	
	$main / in_game / interact_notif / Label.visible = frame >= 3
	$main / in_game / interact_notif / TextureRect.texture.set_current_frame(frame)
	
	$main / in_game / interact_notif.margin_bottom = 12 + sin(OS.get_ticks_msec() * 0.002) * 12
	$main / in_game / interact_notif.visible = interact_timer > 0
	$main / in_game / interact_notif / Label.text = "[E] " + str(int_text)
	
	if menu == MENUS.BACKPACK:
		$main / menu.visible = true
		$main / menu.modulate.a = lerp($main / menu.modulate.a, 1.0, 0.16)
		$main / backpack.visible = true
		$main / backpack.modulate.a = lerp($main / backpack.modulate.a, 1.0, 0.12)
	else:
		$main / menu.visible = $main / menu.modulate.a > 0.05
		$main / menu.modulate.a = lerp($main / menu.modulate.a, 0.0, 0.16)
		$main / backpack.visible = $main / backpack.modulate.a > 0.05
		$main / backpack.modulate.a = lerp($main / backpack.modulate.a, 0.0, 0.12)
	
	if menu == MENUS.BAIT:
		$main / bait_menu.visible = true
		$main / bait_menu.modulate.a = lerp($main / bait_menu.modulate.a, 1.0, 0.16)
		$main / tacklebox.visible = true
		$main / tacklebox.modulate.a = lerp($main / tacklebox.modulate.a, 1.0, 0.12)
	else:
		$main / bait_menu.visible = $main / bait_menu.modulate.a > 0.05
		$main / bait_menu.modulate.a = lerp($main / bait_menu.modulate.a, 0.0, 0.16)
		$main / tacklebox.visible = $main / tacklebox.modulate.a > 0.05
		$main / tacklebox.modulate.a = lerp($main / tacklebox.modulate.a, 0.0, 0.12)

func _hide_hud():
	if not hud_hidden:
		hud_hidden = true
		overlay.modulate.a = 0.0
		PlayerData._send_notification("press h, tab, or esc to show hud again")
	else:
		_show_hud()
	PlayerData.emit_signal("_hide_hud_toggle", hud_hidden)

func _show_hud():
	hud_hidden = false
	overlay.modulate.a = 1.0





func _change_menu(to):
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	
	if menu == MENUS.DIALOGUE and dialogue_cooldown > 0: return
	
	prev_menu = menu
	if menu == to: to = MENUS.DEFAULT
	
	
	if menu != to:
		var sfx = "menu_a"
		match to:
			MENUS.DEFAULT: sfx = "menu_b"
			MENUS.DIALOGUE: sfx = ""
		
		if sfx != "": PlayerData.emit_signal("_play_sfx", sfx)
	
	menu = to
	
	if menu == MENUS.BACKPACK: _open_menu(); else: _close_menu()
	if menu == MENUS.ESC: _open_esc_menu(); else: _close_esc_menu()
	if menu == MENUS.BAIT: _open_bait(); else: _close_bait()
	if menu == MENUS.DEFAULT: overlay.show(); else: overlay.hide()
	if menu == MENUS.SHOP: shop._open(shop_id); else: shop._close()
	if menu == MENUS.DIALOGUE:
		dialogue._open(dialogue_text)
		dialogue_cooldown = 60
	else: dialogue._close()
	if menu == MENUS.EMOTE: emote_wheel._open(); else: emote_wheel._close()
	if menu == MENUS.PROP: prop_menu._open(); else: prop_menu._close()
	
	emit_signal("_menu_entered", menu)
	PlayerData.emit_signal("_inventory_refresh")
	PlayerData.emit_signal("_hotbar_refresh")
	
	
	var rank_data = PlayerData._get_level_data(PlayerData.badge_level)
	$main / menu / Panel3 / badgelabel.text = str(rank_data["title"]) + "\nRANK " + str(PlayerData.badge_level) + "\n" + str(PlayerData.badge_xp) + "/" + str(PlayerData._get_xp_goal(PlayerData.badge_level)) + " xp"
	$main / menu / Panel5 / item_display.texture = rank_data["icon"]





func _open_menu():
	overlay.hide()
	backpack_anim.play("intro", - 1, 2.0)
	_exit_chat()
	$main / menu / tabs / outfit._refresh()
	GlobalAudio._play_sound("backpack_open")

func _close_menu():
	if prev_menu == MENUS.BACKPACK:
		backpack_anim.play("intro", - 1, - 2.0, true)
		player.call_deferred("_change_cosmetics")
		GlobalAudio._play_sound("backpack_close")
	
	overlay.show()

func _change_tab(new):
	backpack_anim.stop(true)
	var anim = ["zip", "zip_b", "zip", "zip_b", "zip", "zip_b"][new]
	backpack_anim.play(anim, - 1, 2.0)
	current_tab = new
	for child in buttons.get_children(): child._update(new)
	for child in tabs.get_children():
		child.visible = child.get_position_in_parent() == new
		if child.get_position_in_parent() == new: $"%bplabel".text = child.name
	
	if menu == MENUS.BACKPACK:
		PlayerData.emit_signal("_play_sfx", "zip")





func _open_esc_menu():
	esc_menu.show()
	esc_menu._open()
	_exit_chat()

func _close_esc_menu():
	esc_menu._close()
	esc_menu.hide()





func _open_bait():
	GlobalAudio._play_sound("tb_rustle")
	overlay.hide()
	tacklebox_anim.play("open", - 1, 2.0)
	_exit_chat()
	_bait_refresh()

func _close_bait():
	if prev_menu == MENUS.BAIT:
		GlobalAudio._play_sound("tb_rustle")
		tacklebox_anim.play("open", - 1, - 2.0, true)
	
	overlay.show()

func _bait_refresh():
	var bait_list = $"%bait_list"
	var lure_list = $"%lure_list"
	
	for child in bait_list.get_children(): child.queue_free()
	for child in lure_list.get_children(): child.queue_free()
	
	for bait in PlayerData.bait_inv.keys():
		if not PlayerData.bait_unlocked.has(bait): continue
		
		var button = Button.new()
		button.set_script(preload("res://Scenes/Menus/Main Menu/ui_generic_button.gd"))
		button.icon = PlayerData.BAIT_DATA[bait].icon
		button.text = PlayerData.BAIT_DATA[bait].name
		button.disabled = PlayerData.bait_selected == bait
		
		if bait != "":
			button.text = button.text + " x" + str(PlayerData.bait_inv[bait])
			if PlayerData.bait_inv[bait] <= 0: button.disabled = true
		
		if PlayerData.bait_selected == bait:
			button.text = button.text + " (selected)"
		
		button.expand_icon = true
		button.align = Button.ALIGN_LEFT
		button.connect("pressed", self, "_change_bait", [bait])
		button.connect("mouse_entered", self, "_bait_hover", [bait])
		bait_list.add_child(button)
	
	for lure in PlayerData.LURE_DATA.keys():
		if not PlayerData.lure_unlocked.has(lure): continue
		
		var button = Button.new()
		button.set_script(preload("res://Scenes/Menus/Main Menu/ui_generic_button.gd"))
		button.icon = PlayerData.LURE_DATA[lure].icon
		button.text = PlayerData.LURE_DATA[lure].name
		button.disabled = PlayerData.lure_selected == lure
		
		if PlayerData.lure_selected == lure:
			button.text = button.text + " (selected)"
		
		button.expand_icon = true
		button.align = Button.ALIGN_LEFT
		button.connect("pressed", self, "_change_lure", [lure])
		button.connect("mouse_entered", self, "_lure_hover", [lure])
		lure_list.add_child(button)

func _change_bait(bait):
	PlayerData.bait_selected = bait
	PlayerData.emit_signal("_bait_update")

func _bait_hover(bait):
	var title = PlayerData.BAIT_DATA[bait].name
	var desc = PlayerData.BAIT_DATA[bait].desc
	$main / bait_menu / Panel3 / bait_info.bbcode_text = "[color=#6a4420]" + title + "[/color]\n" + desc

func _change_lure(lure):
	PlayerData.lure_selected = lure
	PlayerData.emit_signal("_bait_update")

func _lure_hover(lure):
	var title = PlayerData.LURE_DATA[lure].name
	var desc = PlayerData.LURE_DATA[lure].desc
	$main / bait_menu / Panel3 / bait_info.bbcode_text = "[color=#6a4420]" + title + "[/color]\n" + desc






func _item_pressed(item):
	_change_menu(MENUS.DEFAULT)
	player._equip_item(item)

func _exit_chat():
	chat.focus_mode = Control.FOCUS_NONE
	chat.editable = false
	chat.selecting_enabled = false
	chat.placeholder_text = "ENTER to begin typing..."
	using_chat = false

func _refresh_hotbar():
	var index = 0
	for child in hotbar.get_children():
		child.disconnect("pressed", self, "_item_pressed")
		if not PlayerData.hotbar.keys().has(index):
			index += 1
			continue
		
		var item = PlayerData._find_item_code(PlayerData.hotbar[index])
		child._setup_item(item["ref"])
		child.connect("pressed", self, "_item_pressed", [item])
		index += 1

func _send_message(text):
	if text.replace(" ", "") == "": return
	var color = Globals.cosmetic_data[PlayerData.cosmetics_equipped["primary_color"]]["file"].main_color
	color = color.to_html()
	
	
	
	text = text.replace("[", "")
	text = text.replace("]", "")
	
	var breakdown = text.split(" ")
	var final_text = ""
	var spoken_text = ""
	var colon = true
	var current_effect = "none"
	
	
	var drunk_chance = 0.0
	var drunk_max = 0
	if is_instance_valid(player):
		drunk_chance = 0.13 * player.drunk_tier
		drunk_max = player.drunk_tier
	
	var line_index = 0
	for line in breakdown:
		if line.begins_with("/"):
			match line:
				"/me": colon = false
				"/wag": PlayerData.emit_signal("_wag_toggle")
		
		elif line.begins_with("["):
			continue
		
		else:
			var spoken_add = line
			
			
			
			for i in drunk_max:
				var cont = true
				if randf() < drunk_chance and line.length() > 0:
					var d_effect = randi() % 5
					match d_effect:
						0, 1:
							var slot = randi() % line.length()
							line = line.insert(slot, line[slot])
							spoken_add = line
						2:
							var slot = randi() % line.length()
							line = line.insert(slot, "'")
							spoken_add = line
						3:
							var slot = randi() % line.length()
							line = line.insert(slot, ",")
							spoken_add = line
						4:
							var slot = randi() % line.length()
							spoken_add = line.insert(slot, " -*HICC*- ")
							cont = false
				
				if not cont: break
			
			spoken_text = spoken_text + spoken_add
			
			
			final_text = final_text + line
			if breakdown.size() - 1 != line_index:
				spoken_text = spoken_text + " "
				final_text = final_text + " "
			
		line_index += 1
	
	var prefix = ""
	var suffix = ""
	var endcap = ": "
	if not colon:
		prefix = "("
		suffix = ")"
		endcap = " "
	
	var final_color = str((Color(color) * Color(0.95, 0.9, 0.9)).to_html())
	var final = prefix + "%u" + endcap + final_text + suffix
	
	if final_text != "": Network._send_message(final, final_color, chat_local)
	if colon and spoken_text != "": emit_signal("_message_sent", spoken_text)

func _chat_update():
	chat_timer = 210
	gamechat.bbcode_text = str(Network.GAMECHAT) if not chat_local else str(Network.LOCAL_GAMECHAT)

func _button_message_send():
	_send_message(chat.text)
	chat.text = ""
	_exit_chat()

func _request_item_choice(filter_id = [], min_items = 1, max_items = 99, tag_filter = "", ignore_specified = true):
	if popups.has("CHOICE"): return
	popups.append("CHOICE")
	var ic = preload("res://Scenes/HUD/ItemSelect/item_select.tscn").instance()
	ic.tag_filter = tag_filter
	ic.filter = filter_id
	ic.min_items = min_items
	ic.max_items = max_items
	ic.ignore_specified = ignore_specified
	add_child(ic)
	ic.connect("_finished", self, "_select_finished")

func _select_finished(items):
	popups.erase("CHOICE")
	emit_signal("_items_chosen", items)
	PlayerData.emit_signal("_return_item_choice", items)

func _on_Button_pressed():
	_request_item_choice()
	var items = yield(self, "_items_chosen")
	print("CHOSEN: ", items)

func _on_inbox__create_letter():
	if Network.PLAYING_OFFLINE:
		PlayerData._send_notification("Cannot send letters in an Offline game.", 1)
		return
	
	popups.append("LETTER")
	var p = preload("res://Scenes/HUD/Inbox/letter_popup.tscn").instance()
	add_child(p)
	p.hud = self
	p.connect("_finished", self, "_letter_finished")

func _letter_finished():
	popups.erase("LETTER")

func _on_inbox__read_letter(letter):
	popups.append("LETTER_READ")
	var p = preload("res://Scenes/HUD/Inbox/letter_view.tscn").instance()
	add_child(p)
	p._load_letter(letter)
	p.hud = self
	p.connect("_finished", self, "_letter_read_finished")

func _letter_read_finished():
	popups.erase("LETTER_READ")

func _on_dialogue__finished():
	_change_menu(MENUS.DEFAULT)




func _open_minigame(minigame, params = {}, difficulty = 1.0):
	if not MINIGAMES.keys().has(minigame): return
	if popups.has("MINIGAME_" + str(minigame)): return
	
	_abort()
	popups.append("MINIGAME_" + str(minigame))
	var m = MINIGAMES[minigame].instance()
	m.params = params
	m.difficulty = difficulty
	add_child(m)
	var success = yield(m, "_finished")
	emit_signal("_minigame_finished", success)
	popups.erase("MINIGAME_" + str(minigame))

func _abort():
	_change_menu(MENUS.DEFAULT)
	_exit_chat()




func _on_Button4_pressed():
	emit_signal("_player_sit")

func _play_emote(emote_id, emotion):
	emit_signal("_play_emote", emote_id, emotion)
	_change_menu(MENUS.DEFAULT)

func _toggle_chat(extra_arg_0):
	chat_local = not extra_arg_0
	_chat_update()
	
	$"%global_chat".modulate = Color(0.7, 0.7, 0.7) if not extra_arg_0 else Color(1.0, 1.0, 1.0)
	$"%local_chat".modulate = Color(0.7, 0.7, 0.7) if extra_arg_0 else Color(1.0, 1.0, 1.0)

func _on_expand_pressed():
	chat_expand = not chat_expand
	
	if chat_expand:
		$"%expand".icon = preload("res://Assets/Textures/UI/chat_arrow2.png")
	else:
		$"%expand".icon = preload("res://Assets/Textures/UI/chat_arrow1.png")

func _on_hide_pressed():
	chat_hide = true
func _on_show_chat_pressed():
	chat_hide = false


func _quest_update():
	for child in $"%questbox".get_children():
		child.queue_free()
	
	for quest in PlayerData.current_quests.keys():
		if PlayerData.current_quests[quest]["active"]:
			var entry = preload("res://Scenes/HUD/QuestEntry/quest_entry.tscn").instance()
			entry._setup(quest)
			$"%questbox".add_child(entry)

func _quest_toggle():
	$"%questbox".visible = not $"%questbox".visible
	$main / in_game / Label / Button.text = ">" if $"%questbox".visible else "<"

func _on_tent_pressed():
	_change_menu(MENUS.PROP)

func _on_camera_pressed():
	emit_signal("_freecam_toggle")
	

func _on_status_update_timeout():
	if not is_instance_valid(player): return
	
	
	var tier = 0
	if player.boost_timer > 0 and player.boost_timer < 3600: tier = 1
	elif player.boost_timer > 0: tier = 2
	$main / in_game / static_effects / GridContainer / speedboost._setup(tier if player.boost_amt == 1.3 else 0, player.boost_timer)
	$main / in_game / static_effects / GridContainer / speedboost_burst._setup(tier if player.boost_amt == 4.0 else 0, player.boost_timer)
	
	
	tier = 0
	
	if player.catch_drink_timer > 0 and player.catch_drink_timer < 3600: tier = 1
	elif player.catch_drink_timer > 0: tier = 2
	$main / in_game / static_effects / GridContainer / catchboost._setup(tier if player.catch_drink_tier == 1 else 0, player.catch_drink_timer)
	$main / in_game / static_effects / GridContainer / catchboost_big._setup(tier if player.catch_drink_tier == 2 else 0, player.catch_drink_timer)
	$main / in_game / static_effects / GridContainer / catchboost_deluxe._setup(tier if player.catch_drink_tier == 3 else 0, player.catch_drink_timer)
	
	
	tier = 0
	if player.drunk_timer > 0 and player.drunk_timer < 3600: tier = 1
	elif player.drunk_timer > 0: tier = 2
	$main / in_game / static_effects / GridContainer / drunk_tipsy._setup(tier if player.drunk_tier == 1 else 0, player.drunk_timer)
	$main / in_game / static_effects / GridContainer / drunk_reg._setup(tier if player.drunk_tier == 2 else 0, player.drunk_timer)
	$main / in_game / static_effects / GridContainer / drunk_hammered._setup(tier if player.drunk_tier == 3 else 0, player.drunk_timer)
	$main / in_game / static_effects / GridContainer / drunk_fucked._setup(tier if player.drunk_tier == 4 else 0, player.drunk_timer)
	
	
	$main / in_game / static_effects / GridContainer / jump_small._setup(1 if player.jump_bonus_tier == 1 else 0, player.jump_bonus_timer)
	$main / in_game / static_effects / GridContainer / jump_big._setup(1 if player.jump_bonus_tier == 2 else 0, player.jump_bonus_timer)


func _tb_sound_play():
	if menu == MENUS.BAIT: GlobalAudio._play_sound("tb_open")
	else: GlobalAudio._play_sound("tb_close")



func _new_lobby_request(id):
	PlayerData._send_notification(str(Steam.getFriendPersonaName(id)) + " is asking to join the game!")

func _lobby_request_update():
	recent_request = 180
	request_panel.visible = Network.WEB_LOBBY_JOIN_QUEUE.size() > 0
	request_label.text = str(Network.WEB_LOBBY_JOIN_QUEUE.size())
	$main / in_game / player_requests / TooltipNode.body = str(Network.WEB_LOBBY_JOIN_QUEUE.size()) + " players are asking to join your lobby!\nYou can let them in by viewing the PLAYERLIST in your BACKPACK menu!"
	
	$"%request_count".visible = Network.GAME_MASTER and Network.WEB_LOBBY_JOIN_QUEUE.size() > 0
	$"%request_count_b".visible = Network.GAME_MASTER and Network.WEB_LOBBY_JOIN_QUEUE.size() > 0
	$"%request_count_label".text = str(Network.WEB_LOBBY_JOIN_QUEUE.size())
	$"%request_count_label_b".text = str(Network.WEB_LOBBY_JOIN_QUEUE.size())
