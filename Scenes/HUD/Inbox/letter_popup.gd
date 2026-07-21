extends CanvasLayer

var hud
var items_to_send = []

onready var options = $Control / Panel / VBoxContainer / OptionButton
onready var dear_options = $Control / Panel / VBoxContainer / HBoxContainer / OptionButton2
onready var text = $Control / Panel / VBoxContainer / Panel / TextEdit

signal _finished

func _ready():
	$Control / Panel / VBoxContainer / HBoxContainer / namelb.text = str(Network.STEAM_USERNAME)
	
	for member in Network.WEB_LOBBY_MEMBERS:
		var steam_name = Steam.getFriendPersonaName(member)
		options.add_item(steam_name)
	options.select(0)
	_on_OptionButton_item_selected(0)
	
	for item in PlayerData.LETTER_CLOSINGS:
		dear_options.add_item(item)
	dear_options.select(0)

func _on_send_pressed():
	var header = $Control / Panel / VBoxContainer / LineEdit.text
	if header == "": header = "Letter"
	var body = $Control / Panel / VBoxContainer / Panel / TextEdit.text
	var to = 0
	var closing = str(dear_options.get_item_text(dear_options.selected))
	for member in Network.WEB_LOBBY_MEMBERS:
		var steam_name = Steam.getFriendPersonaName(member)
		if steam_name == options.get_item_text(options.selected):
			to = member
	
	var items = []
	for item in PlayerData.inventory:
		if items_to_send.has(item["ref"]):
			items.append(item)
	
	PlayerData._send_letter(to, header, closing, body, items)
	
	queue_free()
	emit_signal("_finished")

func _on_cancel_pressed():
	queue_free()
	emit_signal("_finished")

func _on_Button_pressed():
	hud._request_item_choice([], 1, 20)
	var items = yield(hud, "_items_chosen")
	print("chosen items: ", items)
	
	var lbl = $Control / Panel / VBoxContainer / HBoxContainer2 / Button
	lbl.text = "Add Gifts"
	if items.size() > 0: lbl.text = lbl.text + " (" + str(items.size()) + ")"
	items_to_send = items

func _on_OptionButton_item_selected(index):
	$Control / Panel / VBoxContainer / dear_label.text = "Dear " + str(options.get_item_text(index)) + ", "

func _on_TextEdit_text_changed():
	var text_cap = 500
	if text.text.length() > text_cap:
		text.text = text.text.left(text_cap)
		text.readonly = true
func _input(event):
	if Input.is_action_just_pressed("backspace") and text.has_focus():
		$Control / Panel / VBoxContainer / Panel / TextEdit.readonly = false
