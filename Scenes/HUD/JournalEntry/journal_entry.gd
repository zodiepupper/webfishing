extends Control

var hidden = false

func _setup(id, size, count, quality):
	var data = Globals.item_data[id]["file"]
	
	var n = data.item_name if count > 0 else "UNKNOWN"
	$tooltip_node.header = "[color=#6a4420]" + n + "[/color]"
	
	var d = data.item_description if count > 0 else "CATCH THIS CREATURE TO LEARN MORE ABOUT IT"
	$tooltip_node.body = "[color=#b48141]" + d + "[/color]"
	
	$TextureRect.texture = data.icon if count > 0 else preload("res://Assets/Textures/fishico.png")
	$TextureRect.modulate = Color(0.0, 0.0, 0.0) if count <= 0 else Color(1.0, 1.0, 1.0)
	$Panel.modulate = Color(0.6, 0.6, 0.5) if count <= 0 else Color(1.0, 1.0, 1.0)
	hidden = count <= 0
	
	$quality.visible = count > 0
	for q in PlayerData.ITEM_QUALITIES.size():
		if quality.has(q):
			$quality.get_child(q).texture = preload("res://Assets/Textures/UI/journal_dots2.png")
			$quality.get_child(q).modulate = Color(PlayerData.QUALITY_DATA[q].color)
		else:
			$quality.get_child(q).texture = preload("res://Assets/Textures/UI/journal_dots1.png")
			$quality.get_child(q).modulate = Color(1.0, 1.0, 1.0)
