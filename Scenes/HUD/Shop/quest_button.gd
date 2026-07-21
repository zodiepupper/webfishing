extends Button

var claim = false

func _setup(quest_id, alt = false):
	var data = PlayerData.current_quests[quest_id]
	var body = data.title
	var description = ""
	
	$Panel / Label.text = str(data.tier + 1)
	
	$HBoxContainer / TextureRect.texture = load(data.icon)
	$HBoxContainer / RichTextLabel.bbcode_text = body
	
	$HBoxContainer2 / cash / Label.text = "$" + str(data.gold_reward)
	description = description + "$" + str(data.gold_reward)
	description = description + "\n" + str(data.xp_reward) + "xp"
	
	if data.rewards.size() > data.tier and data.rewards[data.tier] != "":
		var reward = data["rewards"][data["tier"]]
		if reward.begins_with("$"):
			reward.erase(0, 1)
			var rdata = Globals.item_data[reward]["file"]
			$HBoxContainer2 / cosmetic.visible = true
			$HBoxContainer2 / cosmetic / TextureRect.texture = rdata.icon
			$HBoxContainer2 / cosmetic / TextureRect.modulate = Color(1.0, 1.0, 1.0)
			description = description + "\n" + str(rdata.item_name) + " item"
		else:
			if reward.begins_with("*"): reward.erase(0, 1)
			var rdata = Globals.cosmetic_data[reward]["file"]
			$HBoxContainer2 / cosmetic.visible = true
			$HBoxContainer2 / cosmetic / TextureRect.texture = rdata.icon
			$HBoxContainer2 / cosmetic / TextureRect.modulate = rdata.main_color
			description = description + "\n" + str(rdata.name) + " cosmetic"
	else:
		$HBoxContainer2 / cosmetic.visible = false
	
	$TooltipNode.header = "[color=#6a4420]Quest Rewards:[/color]"
	$TooltipNode.body = description
	
	if alt: self_modulate = "#f7eee1"
	else: self_modulate = "#ffffff"
	
	$ProgressBar.max_value = data.goal_amt
	$ProgressBar.value = data.progress
	$ProgressBar / Label.text = str(data.progress) + "/" + str(data.goal_amt)
	if data.progress >= data.goal_amt: $ProgressBar / Label.text = "CLAIM REWARD!"
	claim = data.progress >= data.goal_amt
	
	$confim.visible = data.progress >= data.goal_amt
	
	if data.hidden:
		$HBoxContainer / RichTextLabel.bbcode_text = "Catch ???"
		$HBoxContainer / TextureRect.texture = load("res://Assets/Textures/questionmark2.png")

func _process(delta):
	$ProgressBar / Label.modulate.a = 1.0 if not claim else 0.6 + (sin(OS.get_ticks_msec() * 0.006) * 0.4)
	$confim.modulate.a = 0.6 + (sin(OS.get_ticks_msec() * 0.006) * 0.4)
