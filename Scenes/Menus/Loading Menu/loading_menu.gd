extends Control

var waiting = false
var canceled = false

var label_text = ""
var dots = ""
var t = 0

var connection_attempts = 0
var connection_wait = 0

var used_tips = []
var jingle_played = false

onready var label = $CenterContainer / VBoxContainer / main
onready var tip_label = $CenterContainer / VBoxContainer / tips

func _ready():
	_set_new_tip()
	
	if Network.PLAYING_OFFLINE:
		_set_label_text("creating world")
		yield(get_tree().create_timer(2.0), "timeout")
		_join_world()
	else:
		Network.connect("_denied_into_weblobby", self, "_denied")
		_set_label_text("asking to join lobby")
		waiting = true
		$cancel.visible = not Network.CREATING_SERVER

func _on_Timer_timeout():
	
	
	t += 1
	if t >= 4: t = 0
	dots = ""
	for i in t: dots = dots + "."
	label.text = label_text + dots
	
	
	if not waiting or canceled: return
	
	if Network.CREATING_SERVER:
		waiting = false
		_set_label_text("creating world")
		yield(get_tree().create_timer(2.0), "timeout")
		_join_world()
		return
	
	Network._ask_to_join_weblobby()
	
	if Network.IN_WEB_LOBBY:
		if not jingle_played:
			jingle_played = true
			GlobalAudio._play_sound("request_jingle_allowed")
		
		connection_wait += 1
		if connection_wait > 12:
			connection_wait = 0
			connection_attempts += 1
			Network._retry_connections()
		
		if connection_attempts > 0: _set_label_text("connecting to world" + " (attempt " + str(connection_attempts + 1) + ")")
		else: _set_label_text("connecting to world")
		
		if Network.WEB_LOBBY_MEMBERS.size() > 1:
			waiting = false
			_set_label_text("creating world")
			yield(get_tree().create_timer(2.0), "timeout")
			_join_world()

func _join_world():
	if canceled: return
	
	waiting = false
	SceneTransition._change_scene("res://Scenes/World/world.tscn", 0.3, false, true)

func _denied(reason):
	if canceled: return
	canceled = true
	
	match reason:
		Network.DENY_REASONS.DENIED: PopupMessage._show_popup("You were denied entry to this lobby.")
		Network.DENY_REASONS.LOBBY_FULL: PopupMessage._show_popup("This lobby is full.")
	
	GlobalAudio._play_sound("request_jingle_denied")
	yield(PopupMessage, "_closed")
	Globals._exit_game()

func _set_label_text(new):
	label_text = new
	label.text = new + dots

func _on_cancel_pressed():
	canceled = true
	Globals._exit_game()

func _on_tip_timer_timeout():
	var tween = get_tree().create_tween()
	tween.tween_property(tip_label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(self, "_set_new_tip")
	tween.tween_property(tip_label, "modulate:a", 1.0, 1.0)

func _set_new_tip():
	randomize()
	var tips = [
		"Fish tend to like it if you've moved your bobber recently!", 
		"It's Fishing: [color=#d5aa73]On The Web![/color]", 
		"im aware its not technically 'on the web', but 'OnlineConnectionFishing' doesnt quite have the same ring", 
		"The bigger and rarer the Fish- the more it sells for!", 
		"You can invest your money on new [color=#d5aa73]Bait[/color] types and upgrades to get bigger and better Fish!", 
		"Be sure to keep your [color=#d5aa73]Bait[/color] stocked! Can't catch any Fish without bait!", 
		"the [color=#d5aa73]void[/color] does not exist.", 
		"Pressing [color=#d5aa73]Jump[/color] while in the air makes you [color=#d5aa73]Dive[/color] forward!", 
		"Fish tend to be more active where it's raining!", 
		"You can store a single fish in the [color=#d5aa73]Aquarium[/color] for all other [color=#d5aa73]WEBFISHERS[/color] to see!", 
		"You can [color=#d5aa73]Right Click[/color] an item in your inventory to [color=#d5aa73]Favorite[/color] it- preventing it from being sold!", 
		"You can press the [color=#d5aa73]1-5 Number Keys[/color] to put an item onto your hotbar!", 
		"You can [color=#d5aa73]Sneak[/color] by holding your [color=#d5aa73]Sneak[/color] key (by default, [color=#d5aa73]CTRL[/color])! [color=#d5aa73]Sneak[/color]ing does nothing. Yeah.", 
		"Fish can roll.", 
		"Be sure to swap up what [color=#d5aa73]Lure[/color] you're using to fit the type of fish you're trying to catch!", 
		"Check in on your [color=#d5aa73]Questboard[/color] to get rewards for completing [color=#d5aa73]Quests[/color]!", 
		"[color=#d5aa73]Ripples[/color] have a guaranteed Fish catch in them, as well as having a higher chance of rewarding higher quality Fish!", 
		"I've heard shooting stars are quite common to see around [color=#d5aa73]Pawprint Point[/color]...", 
		"Be sure to get some drinks from the [color=#d5aa73]Vending Machine[/color]!", 
		"[color=#d5aa73]Pawprint Point[/color]: Come for the Fishing, stay for the Gambling!", 
		"[color=#d5aa73]WEBFISHING![/color] We-B-Fishing!", 
		"Pro Fishing Tip: [color=#d5aa73]Hydrate![/color]", 
		"If you delete your save files you will lose your progress!", 
		"you can love a fish but a fish can never love you back", 
		"Use [color=#d5aa73]Super Bounce Brew[/color] to explore areas that might seem unreachable, like behind walls!", 
		"God I Love Fishing!", 
		"Despite the name, this game is [color=#d5aa73]100% spider free[/color].", 
		"ti- ...wait what did anyone else just see that?", 
		"[color=#d5aa73]Noun[/color], The pointed or rounded end or extremity of something slender or tapering.", 
		"if you ignore it, maybe it will go away", 
		"Size doesn't matter! Unless...", 
		"Uninstalling this game will delete it!", 
		"You can change the level of pixelization in the game options, to your preference!", 
		"run.", 
		"Click as fast as you can to break down [color=#d5aa73]barriers[/color] while fishing!", 
		"Many of the face sprites and cosmetics were made by wonderful and talented artists, which you can see in the credits!"
	]
	for tip in used_tips:
		tips.erase(tip)
	
	var new_tip = tips[randi() % tips.size()]
	used_tips.append(new_tip)
	if used_tips.size() > 10: used_tips.clear()
	
	tip_label.bbcode_text = "[center]TIP: " + new_tip
