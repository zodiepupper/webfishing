extends Control

var default_name = ""
var custom_name = ""
var lobby_tags = []
var lobby_dated = false

var label_toggle = true

onready var lobby_label = $Panel / HBoxContainer / Label
onready var lobby_tag_label = $Panel / HBoxContainer / tags
onready var playercount = $Panel / HBoxContainer2 / players
onready var button = $Panel / HBoxContainer2 / Button

signal _pressed

func _setup(lobby_default_name, lobby_name, player_count, player_count_total, player_limit, tags, dated, request):
	
	playercount = $Panel / HBoxContainer2 / players
	button = $Panel / HBoxContainer2 / Button
	lobby_label = $Panel / HBoxContainer / Label
	lobby_tag_label = $Panel / HBoxContainer / tags
	
	
	default_name = lobby_default_name
	custom_name = lobby_name
	_update_lobby_name()
	
	
	var tag_text = ""
	var index = 0
	for tag in Network.LOBBY_TAGS:
		if not tags.has(tag): continue
		var tag_entry = tag.capitalize()
		var color = "#d5aa73"
		
		match tag:
			"mature":
				tag_entry = "Mature (18+)"
				color = "#ac0029"
			"modded":
				tag_entry = "Modded"
				color = "#ac0029"
		
		tag_text = tag_text + "[color=" + str(color) + "]" + tag_entry + "[/color]"
		if index < tags.size() - 1: tag_text = tag_text + ", "
		index += 1
	if tag_text == "":
		tag_text = "(No Tags)"
	
	lobby_tag_label.bbcode_text = str(tag_text)
	
	var cap = str(player_limit)
	if cap == "": cap = str(12)
	var in_queue = int(player_count_total) - int(player_count)
	var queue_add = "" if in_queue <= 0 else "(+" + str(in_queue) + ")"
	
	if in_queue < 0:
		queue_add = ""
		player_count = player_count_total
	
	playercount.text = str(player_count) + queue_add + "/" + str(cap)
	button.disabled = int(player_count) >= int(cap) or dated
	
	$"%request".visible = request
	
	button.text = "Join"
	if request:
		button.text = "Ask to Join"
		$Panel / HBoxContainer2 / Button / TooltipNode.header = "Ask to Join Lobby"
		$Panel / HBoxContainer2 / Button / TooltipNode.body = "This lobby has REQUESTS turned on, thus when joining you'll have to wait until they allow you to enter!"
	
	if dated: button.text = "Outdated"

func _on_Button_pressed():
	emit_signal("_pressed")

func _label_toggle(toggled):
	label_toggle = toggled
	_update_lobby_name()

func _update_lobby_name():
	var new_name = str(default_name) + "'s Lobby"
	if label_toggle and custom_name != "":
		new_name = SwearFilter._filter_string(str(custom_name))
	
	new_name = new_name.replace("[", "")
	new_name = new_name.replace("]", "")
	if new_name.length() > 40:
		new_name = new_name.left(40)
		new_name = new_name + "... "
	
	lobby_label.bbcode_text = new_name

func _disable():
	$Panel / HBoxContainer2 / Button.disabled = true
