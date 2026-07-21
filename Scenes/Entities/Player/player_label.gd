extends Control

var label = ""
var title = ""
var player_id = - 1

func _update_title():
	var _name = label
	_name = label.replace("[", "")
	_name = _name.replace("]", "")
	if Network.KNOWN_DEVELOPERS.has(player_id): _name = "[color=#e69d00][LAMEDEV][/color]\n" + _name
	if Network.KNOWN_CONTRIBUTORS.has(player_id): _name = "[color=#008583][CONTRIBUTOR][/color]\n" + _name
	
	$VBoxContainer / Label.bbcode_text = "[center]" + _name
	$VBoxContainer / Label2.text = title

func _create_speech_bubble(text, speed = 0.05):
	if OptionsMenu.chat_filter:
		text = SwearFilter._filter_string(text)
	
	var bubble = preload("res://Scenes/Entities/Player/SpeechBubble/speech_bubble.tscn").instance()
	bubble.final_text = text
	bubble.speed = speed
	$bubble_box.add_child(bubble)
	return bubble

func _create_level_bubble():
	var bubble = preload("res://Scenes/Entities/Player/SpeechBubble/level_bubble.tscn").instance()
	$bubble_box.add_child(bubble)
	return bubble
