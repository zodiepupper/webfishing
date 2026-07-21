extends Control

var open = false
var cooldown = 0

onready var gridcont = $Panel / ScrollContainer / VBoxContainer / HBoxContainer / GridContainer

func _ready():
	PlayerData.connect("_prop_update", self, "_refresh")
	_refresh()

func _physics_process(delta):
	rect_position.y = lerp(rect_position.y, 184 if open else 600, 0.15)
	if cooldown > 0: cooldown -= 1
	
	modulate.a = lerp(modulate.a, 1.0 if open else 0.0, 0.2)
	visible = modulate.a > 0.1

func _refresh():
	for child in gridcont.get_children(): child.queue_free()
	
	var ids = []
	for entry in PlayerData.props_placed:
		ids.append(entry.ref)
	
	for item in PlayerData.inventory:
		if not item.keys().has("id") or not Globals._item_exists(item.id): continue
		
		var idata = Globals.item_data[item["id"]]["file"]
		if idata.category != "furniture": continue
		
		var button = preload("res://Scenes/HUD/PropButton/prop_button.tscn").instance()
		button.icon = idata.icon
		button.get_node("TooltipNode").header = idata.item_name
		button.get_node("TooltipNode").body = idata.item_description
		button.get_node("Panel").visible = ids.has(item["ref"])
		button.connect("pressed", self, "_place", [item["ref"]])
		
		gridcont.add_child(button)

func _place(ref):
	if cooldown > 0: return
	cooldown = 15
	PlayerData.emit_signal("_place_prop", ref)

func _open():
	open = true
	_refresh()
func _close(): open = false

func _on_Button_pressed():
	PlayerData.emit_signal("_clear_all_props")
