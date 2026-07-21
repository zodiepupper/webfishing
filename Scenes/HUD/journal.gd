extends Control

var journal_category = "fish"
var journal_index = 0
var scroll_index = 0

onready var box = $Panel / MarginContainer / HScrollBar / GridContainer

func _ready():
	
	var index = 0
	for category in [\
	["freshwater", ["lake"]], \
	["saltwater", ["ocean"]], \
	["misc", ["water_trash", "deep", "rain", "alien", "void"]]]:
		
		var button = Button.new()
		button.set_script(preload("res://Scenes/Menus/Main Menu/ui_generic_button.gd"))
		button.text = str(category[0]).to_upper()
		button.size_flags_horizontal = SIZE_EXPAND_FILL
		button.size_flags_vertical = SIZE_EXPAND_FILL
		button.connect("pressed", self, "_change_category", [category[1], index])
		$journal_buttons.add_child(button)
		
		index += 1
	
	_change_category(["lake"], 0)
	PlayerData.connect("_journal_update", self, "_refresh")

func _refresh():
	_change_category(journal_category, journal_index)

func _change_category(categories, index):
	print(categories)
	journal_category = categories
	journal_index = index
	
	for child in $journal_buttons.get_children(): child.modulate = Color(0.7, 0.7, 0.7)
	$journal_buttons.get_child(index).modulate = Color(1.0, 1.0, 1.0)
	
	for child in box.get_children(): child.queue_free()
	
	var count = 0
	var quality_count = []
	
	for cat in PlayerData.journal_logs.keys():
		if not categories.has(cat): continue
		
		for key in PlayerData.journal_logs[cat].keys():
			var data = PlayerData.journal_logs[cat][key]
			
			var entry = preload("res://Scenes/HUD/JournalEntry/journal_entry.tscn").instance()
			box.add_child(entry)
			entry._setup(key, data["record"], data["count"], data["quality"])
			entry.connect("mouse_entered", self, "_item_entered", [entry, key, data])
			
			count += 1
			quality_count.append_array(data["quality"])
	
	var desc = "Progress for " + $journal_buttons.get_child(index).text + ": "
	
	for q in PlayerData.ITEM_QUALITIES.size():
		print(q, "  ", quality_count.count(q))
		$prog.get_child(q).max_value = count
		$prog.get_child(q).value = quality_count.count(q)
		
		var qdata = PlayerData.QUALITY_DATA[q]
		desc = desc + "\n[color=" + str(qdata.color) + "]" + qdata.title + "[/color]: " + str(quality_count.count(q)) + "/" + str(count) + "(" + str(floor(float(quality_count.count(q)) / float(count) * 100.0)) + "%)"
	
	$prog / TooltipNode.header = "Journal Progress"
	$prog / TooltipNode.body = desc

func _item_entered(button, item, entry):
	if not Globals.item_data.keys().has(item): return
	var data = Globals.item_data[item]["file"]
	
	$Panel2 / item_display._setup_nonitem(data.icon, button.hidden)
	
	var n = str(data.item_name) if not button.hidden else "UNKNOWN"
	$Panel3 / header.bbcode_text = "[color=#6a4420]" + n + "[/color]"
	
	var desc = "[color=#b48141]" + str(data.item_description) + "[/color]\n" + str(data.catch_blurb) + "\n[color=#6a4420]Tier:[/color] " + str(data.tier + 1) + "\n[color=#6a4420]Caught:[/color] " + str(entry["count"]) + "\n[color=#6a4420]Record Size:[/color] " + str(entry["record"])
	$Panel3 / body.bbcode_text = desc if not button.hidden else "CATCH THIS CREATURE TO LEARN MORE ABOUT IT"

func _on_Timer_timeout():
	scroll_index += 1
	if scroll_index > $Panel3 / body.get_visible_line_count() - 5: scroll_index = 0
	$Panel3 / body.scroll_to_line(scroll_index)
