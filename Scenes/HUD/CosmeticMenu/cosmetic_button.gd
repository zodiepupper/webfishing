extends Button

var saved_id = ""
var saved_category = ""

signal _pressed_right

func _setup(id):
	PlayerData.connect("_clear_new", self, "_refresh")
	
	var data = Globals.cosmetic_data[id]["file"]
	saved_id = id
	saved_category = data.category
	
	if data.category != "title": $TextureRect.texture = data.icon
	if data.category == "title":
		text = " " + str(data.name) + " "
		rect_min_size.y = 24
	
	$TextureRect.self_modulate = data.main_color * 0.98
	$tooltip_node.header = "[color=#6a4420]" + data.name + "[/color]"
	$tooltip_node.body = data.desc
	_refresh()

func _refresh():
	if not PlayerData.cosmetics_equipped.keys().has(saved_category): return
	
	var equipped = false
	var equip_id = PlayerData.cosmetics_equipped[saved_category]
	
	if saved_category != "accessory":
		if equip_id is Array:
			equip_id = equip_id[0]
		equipped = equip_id == saved_id
	else:
		equipped = equip_id.has(saved_id)
	
	$ColorRect.visible = equipped
	modulate = Color(1.0, 1.0, 1.0) if not equipped else Color(0.95, 0.95, 0.9)
	
	$TextureRect2.visible = PlayerData.new_cosmetics.has(saved_id)

func _on_Button_mouse_entered():
	GlobalAudio._play_sound("swish")
	if PlayerData.new_cosmetics.has(saved_id):
		PlayerData.new_cosmetics.erase(saved_id)
		PlayerData.emit_signal("_clear_new")

func _on_Button_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_RIGHT:
			emit_signal("_pressed_right")

func _on_Button_pressed():
	GlobalAudio._play_sound("equip_cos")
