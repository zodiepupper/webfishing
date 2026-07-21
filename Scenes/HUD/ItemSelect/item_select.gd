extends CanvasLayer

var selected = []
var filter = []
var tag_filter = ""
var min_items = 1
var max_items = 99
var ignore_specified = false

signal _finished(items)

func _ready():
	var box = $Control / Panel / Control / ScrollContainer / GridContainer
	
	for child in box.get_children(): child.queue_free()
	
	var index = 0
	for item in PlayerData.inventory:
		if filter != [] and not filter.has(item["id"]): continue
		if tag_filter != "": if not item.keys().has("tags") or not item["tags"].has(tag_filter): continue
		
		if ignore_specified:
			if Globals.item_data[item["id"]]["file"].unselectable: continue
			if PlayerData.locked_refs.has(item["ref"]): continue
		else:
			if Globals.item_data[item["id"]]["file"].unrenamable: continue
		
		var i = preload("res://Scenes/HUD/inventory_item.tscn").instance()
		box.add_child(i)
		i._setup_item(item["ref"])
		i.slot = index
		i.connect("pressed", self, "_item_pressed", [i, item])
		index += 1
	
	$Control / Label.text = "SELECT ITEMS (0/" + str(max_items) + ")"


func _process(delta):
	$Control / HBoxContainer / confirm.disabled = selected.size() < min_items or selected.size() > max_items

func _item_pressed(slot, item):
	if slot.highlighted:
		selected.erase(item["ref"])
		slot._highlight( not slot.highlighted)
	elif selected.size() < max_items:
		selected.append(item["ref"])
		slot._highlight( not slot.highlighted)
	$Control / Label.text = "SELECT ITEMS (" + str(selected.size()) + "/" + str(max_items) + ")"

func _on_cancel_pressed():
	emit_signal("_finished", [])
	call_deferred("queue_free")
func _on_confirm_pressed():
	emit_signal("_finished", selected)
	call_deferred("queue_free")
