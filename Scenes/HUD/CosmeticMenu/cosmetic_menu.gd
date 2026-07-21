extends Control

var model
var category = ""

var selected_cosmetic = ""
var selected_category = ""
var selected_style = 0

onready var grid = $Panel4 / Control / GridContainer
onready var categories = $Panel4 / Control / categories
onready var label = $Panel4 / Control / Label

signal _cosmetic_update

func _ready():
	$"%next_style".connect("pressed", self, "_change_style", [1])
	$"%prev_style".connect("pressed", self, "_change_style", [ - 1])
	
	PlayerData.connect("_clear_new", self, "_update_new")
	
	_refresh()
	_change_tab("body")
	
	model = preload("res://Scenes/Entities/Player/player.tscn").instance()
	model.dead_actor = true
	model.delete_on_owner_disconnect = false
	$Panel3 / player_view / Viewport.add_child(model)
	model.call_deferred("_change_cosmetics")

func _change_tab(tab):
	category = tab
	$HBoxContainer / body.modulate = Color(0.7, 0.7, 0.7) if category != "body" else Color(1.0, 1.0, 1.0)
	$HBoxContainer / face.modulate = Color(0.7, 0.7, 0.7) if category != "face" else Color(1.0, 1.0, 1.0)
	$HBoxContainer / clothes.modulate = Color(0.7, 0.7, 0.7) if category != "clothes" else Color(1.0, 1.0, 1.0)
	$HBoxContainer / misc.modulate = Color(0.7, 0.7, 0.7) if category != "misc" else Color(1.0, 1.0, 1.0)
	
	for child in $Panel4 / tabs.get_children():
		child.visible = child.name == tab

func _refresh():
	var griddata = {
		"species": $"%species_cont", 
		"pattern": $"%pattern_cont", 
		"primary_color": $"%primary_color_cont", 
		"secondary_color": $"%sec_color_cont", 
		"tail": $"%tail_cont", 
		
		"eye": $"%eye_cont", 
		"nose": $"%nose_cont", 
		"mouth": $"%mouth_cont", 
		
		"hat": $"%hat_cont", 
		"undershirt": $"%undershirt_cont", 
		"overshirt": $"%overshirt_cont", 
		"legs": $"%leg_cont", 
		"accessory": $"%acc_cont", 
		
		"title": $"%title_cont", 
		"bobber": $"%bob_cont", 
	}
	
	for key in griddata.keys():
		for child in griddata[key].get_children():
			child.queue_free()
	
	var bulk = 0
	for cosm in PlayerData.cosmetics_unlocked:
		if not Globals._cosmetic_exists(cosm): continue
		
		var data = Globals.cosmetic_data[cosm]["file"]
		if not griddata.keys().has(data.category): continue
		
		var button = preload("res://Scenes/HUD/CosmeticMenu/cosmetic_button.tscn").instance()
		
		button._setup(cosm)
		button.connect("pressed", self, "_cosmetic_select", [data.category, cosm])
		connect("_cosmetic_update", button, "_refresh")
		griddata[data.category].add_child(button)
		
		bulk += 1
		if bulk > 8:
			bulk = 0
			yield(get_tree(), "idle_frame")
	
	_update_new()

func _update_new():
	$HBoxContainer / body / new_icon.visible = false
	$HBoxContainer / face / new_icon.visible = false
	$HBoxContainer / clothes / new_icon.visible = false
	$HBoxContainer / misc / new_icon.visible = false
	
	for cosm in PlayerData.new_cosmetics:
		var data = Globals.cosmetic_data[cosm]["file"]
		match data.category:
			"species", "pattern", "primary_color", "secondary_color", "tail": $HBoxContainer / body / new_icon.visible = true
			"eye", "nose", "mouth": $HBoxContainer / face / new_icon.visible = true
			"hat", "undershirt", "overshirt", "accessory": $HBoxContainer / clothes / new_icon.visible = true
			"title", "bobber": $HBoxContainer / misc / new_icon.visible = true

func _cosmetic_select(category, id, style = 0):
	
	
	
	
	
	
	if category != "accessory":
		PlayerData._change_cosmetic(category, id)
	else:
		PlayerData._change_accessory(id)
	
	if model: model._change_cosmetics()
	emit_signal("_cosmetic_update")

func _cosmetic_highlight(category, id, style = - 1):
	return
	
	selected_category = category
	selected_cosmetic = id
	
	var cos_data = Globals.cosmetic_data[id]["file"]
	if style == - 1: selected_style = max(0, cos_data.styles.find(PlayerData.cosmetics_equipped[category]))
	else: selected_style = style
	
	$Panel3 / style_display / HBoxContainer / VBoxContainer / Label2.text = "style " + str(selected_style + 1) + "/" + str(cos_data.styles.size())

func _change_style(modif):
	return
	
	var cos_data = Globals.cosmetic_data[selected_cosmetic]["file"]
	
	selected_style += modif
	if selected_style >= cos_data.styles.size(): selected_style = 0
	if selected_style < 0: selected_style = cos_data.styles.size() - 1
	
	_cosmetic_select(selected_category, selected_cosmetic, selected_style)

func _on_HScrollBar_value_changed(value):
	model.rotation_degrees.y = value
