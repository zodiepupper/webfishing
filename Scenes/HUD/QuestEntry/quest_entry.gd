extends Control

func _setup(quest_id):
	var data = PlayerData.current_quests[quest_id]
	var a = Globals.item_data[data["goal_item"]]["file"]
	var n = a.item_name
	
	if data["type_based"] != "":
		match data["type_based"]:
			"lake":
				a = Globals.item_data["fish_lake_salmon"]["file"]
				n = "Lake Fish"
	
	$ColorRect.visible = data["progress"] >= data["goal_amt"]
	var c_add = "" if data["progress"] < data["goal_amt"] else "[color=#9ca539]"
	
	$RichTextLabel.bbcode_text = "Catch [color=#5a755a]" + str(n) + "[/color]" + c_add + " (" + str(data["progress"]) + "/" + str(data["goal_amt"]) + ") "
	$TextureRect.texture = a.icon
