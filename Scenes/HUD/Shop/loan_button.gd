extends GenericUIButton

var hud

var slot_name = "Camp Tier Increase"
var slot_desc = "Pay towards increasing your CAMP TIER, giving you many benefits!"

var pay_amt = 10

func _ready():
	PlayerData.connect("_loan_update", self, "_refresh")
	_refresh()

func _refresh():
	pay_amt = [10, 100, 500, 500][PlayerData.loan_level]
	
	$HBoxContainer / RichTextLabel.bbcode_text = "CAMP TIER: " + str(PlayerData.loan_level + 1)
	$HBoxContainer2 / cash / Label.text = "Pay $" + str(pay_amt)
	$ProgressBar.value = PlayerData.LOAN_DATA[PlayerData.loan_level] - PlayerData.loan_left
	$ProgressBar.max_value = PlayerData.LOAN_DATA[PlayerData.loan_level]
	$ProgressBar / Label.text = "$" + str(PlayerData.loan_left) + " REMAINING"
	
	if PlayerData.loan_level >= 3:
		$HBoxContainer2 / cash / Label.text = "MAXED"
		$ProgressBar / Label.text = "MAX LEVEL"
		$ProgressBar.value = PlayerData.LOAN_DATA[PlayerData.loan_level]

func _physics_process(delta):
	self_modulate.a = lerp(self_modulate.a, 1.0, 0.06)

func _on_Button_pressed():
	if PlayerData.money < pay_amt or PlayerData.loan_level > 2: return
	PlayerData.loan_left -= pay_amt
	PlayerData.money -= pay_amt
	PlayerData.emit_signal("_float_number", "paid!", "#a4aa39", - 0.4, get_global_mouse_position())
	PlayerData.emit_signal("_shop_update")
	
	self_modulate.a = 0.35
	
	if PlayerData.loan_left <= 0:
		var item_give = ["prop_island_tiny", "prop_island_med", "prop_island_big", ""][PlayerData.loan_level]
		
		if item_give != "": PlayerData._add_item(item_give)
		
		PlayerData.loan_level += 1
		PlayerData.loan_left = PlayerData.LOAN_DATA[PlayerData.loan_level]
		
		match PlayerData.loan_level:
			1: Network._unlock_achievement("camp_tier_2")
			2: Network._unlock_achievement("camp_tier_3")
			3: Network._unlock_achievement("camp_tier_4")
		
		hud._change_menu(0)
		yield(get_tree().create_timer(0.1), "timeout")
		
		GlobalAudio._play_sound("jingle_win")
		hud.dialogue_text = ["Nice! You've increased your CAMP RANK!\nYou've unlocked a new [color=#e69d00]PRIVATE ISLAND[/color] prop and additional items in the shops have been unlocked!"]
		hud._change_menu(6)
		hud.player._play_emote("emote_cheer", "happy")
		hud.player.lvlparticle.restart()
		hud.player.lvlparticleb.restart()
		
		hud.player.force_cam_look = true
		yield(get_tree().create_timer(0.1), "timeout")
		hud.player.cam_follow_node = $catch_cam_position
	
	PlayerData.emit_signal("_loan_update")
