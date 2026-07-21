extends Control

var hovered_slot

var page = 0
var items_per_page = 24
var tab_type = "tool"

onready var item_grid = $Panel / items
onready var prev_page = $Panel / HBoxContainer / prev_page
onready var next_page = $Panel / HBoxContainer / next_page

func _ready():
	PlayerData.connect("_inventory_refresh", self, "_refresh")
	prev_page.connect("pressed", self, "_prev_page")
	next_page.connect("pressed", self, "_next_page")
	
	$tabs / tab_tool.connect("pressed", self, "_change_tab", ["tool"])
	$tabs / tab_creatures.connect("pressed", self, "_change_tab", ["fish"])
	
	_change_tab("tool")
	
	$Panel2 / item_display.texture = null
	$Panel3 / header.bbcode_text = ""
	$Panel3 / body.bbcode_text = ""

func _process(delta):
	if is_instance_valid(hovered_slot) and is_visible_in_tree():
		if Input.is_action_just_pressed("bind_1"): PlayerData._bind_hotbar_slot(0, hovered_slot.slot)
		if Input.is_action_just_pressed("bind_2"): PlayerData._bind_hotbar_slot(1, hovered_slot.slot)
		if Input.is_action_just_pressed("bind_3"): PlayerData._bind_hotbar_slot(2, hovered_slot.slot)
		if Input.is_action_just_pressed("bind_4"): PlayerData._bind_hotbar_slot(3, hovered_slot.slot)
		if Input.is_action_just_pressed("bind_5"): PlayerData._bind_hotbar_slot(4, hovered_slot.slot)

func _refresh(to_page = - 1):
	if to_page == - 1: to_page = page
	
	var valid_items = []
	for item in PlayerData.inventory:
		var data = Globals.item_data[item["id"]]["file"]
		if data.category == tab_type: valid_items.append(item)
	
	var max_pages = floor((valid_items.size() - 1) / items_per_page)
	to_page = clamp(to_page, 0, max_pages)
	
	page = to_page
	
	var start_selection = to_page * items_per_page
	var end_selection = (to_page + 1) * items_per_page
	
	for child in item_grid.get_children(): child.queue_free()
	
	print("Refreshing Inv page ", to_page, " s: ", start_selection, " to ", end_selection)
	
	var total_items = 0
	for i in items_per_page * 5:
		var slot = start_selection + i
		
		if slot >= valid_items.size():
			break
		
		var item = valid_items[slot]
		
		var data = Globals.item_data[item["id"]]["file"]
		if data.item_is_hidden or data.category != tab_type:
			i += 1
			continue
		
		var button = preload("res://Scenes/HUD/inventory_item.tscn").instance()
		item_grid.add_child(button)
		button._setup_item(item["ref"])
		button.slot = PlayerData.inventory.find(item)
		button.connect("pressed", owner, "_item_pressed", [item])
		button.connect("_right_click", self, "_item_locked", [item["ref"]])
		button.connect("mouse_entered", self, "_item_entered", [button, item])
		button.connect("mouse_exited", self, "_item_exited", [button])
		
		total_items += 1
		if total_items >= items_per_page: break
	
	prev_page.disabled = to_page == 0
	next_page.disabled = max_pages <= page
	$Panel / HBoxContainer / Label.text = str(page + 1) + " / " + str(max_pages + 1)

func _next_page():
	_refresh(page + 1)
func _prev_page():
	_refresh(page - 1)
func _change_tab(type):
	tab_type = type
	_refresh(0)
	
	
	$tabs / tab_tool.disabled = tab_type == "tool"
	$tabs / tab_creatures.disabled = tab_type == "fish"

func _item_entered(button, item):
	hovered_slot = button
	
	if not Globals.item_data.keys().has(item["id"]): return
	var data = Globals.item_data[item["id"]]["file"]
	
	
	
	
	var scene_root = $Panel2 / ViewportContainer / inv_preview / root / item / scene
	var sprite = $Panel2 / ViewportContainer / inv_preview / root / item / Sprite3D
	var root = $Panel2 / ViewportContainer / inv_preview / root
	
	for child in scene_root.get_children(): child.queue_free()
	sprite.texture = null
	
	if data.show_scene:
		var new = data.item_scene.instance()
		scene_root.add_child(new)
		
		
		if data.arm_value == 0.3: scene_root.rotation_degrees.z = 0
		else: scene_root.rotation_degrees.z = 90
		
	else:
		sprite.texture = data.icon.duplicate()
	
	var scale_mult = 0.07 - clamp(item["size"] * 0.01, 0.01, 0.061)
	var item_scale = 1.0 if not data.uses_size else item["size"] * scale_mult
	sprite.scale = Vector3(item_scale, item_scale, item_scale)
	
	root.des_cam = 3.4 * item_scale
	root.des_height = 1.5 * item_scale
	
	var podium = $Panel2 / ViewportContainer / inv_preview / root / MeshInstance
	podium.translation.y = 0.9 if item_scale < 2.2 else - 0.5
	
	var quality = $Panel2 / ViewportContainer / inv_preview / root / item / Sprite3D / quality
	for child in quality.get_children(): child.emitting = false
	if PlayerData.QUALITY_DATA.has(item["quality"]):
		sprite.modulate = Color(PlayerData.QUALITY_DATA[item["quality"]]["mod"])
		sprite.opacity = PlayerData.QUALITY_DATA[item["quality"]]["op"]
		if PlayerData.QUALITY_DATA[item["quality"]]["particle"] > - 1: quality.get_child(PlayerData.QUALITY_DATA[item["quality"]]["particle"]).emitting = true
	
	$Panel3 / header.bbcode_text = "[color=#6a4420]" + str(data.item_name) + "[/color]"
	var desc = str(data.item_description) + "\n" + str(data.catch_blurb)
	if data.uses_size:
		desc = desc + "\n" + str(item["size"]) + "cm "
	$Panel3 / body.bbcode_text = desc

func _item_exited(item):
	if hovered_slot == item: hovered_slot = null

func _item_locked(ref):
	PlayerData._lock_item(ref)
