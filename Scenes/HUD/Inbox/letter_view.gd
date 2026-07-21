extends CanvasLayer

var hud
var saved_data

onready var text = $Control / Control / Panel / RichTextLabel
onready var text_end = $Control / Control / Panel / RichTextLabel2

signal _finished

func _load_letter(data):
	saved_data = data
	var header = str(data["header"])
	var body = str(data["body"])
	var is_encoded = PlayerData._is_base64_encoded(body)
	
	if is_encoded:
		header = Marshalls.base64_to_utf8(header)
		body = Marshalls.base64_to_utf8(body)
		print("Letter is Base64")
	else:
		print("Letter is Legacy")
	
	text.text = str(header) + "\n\n" + "Dear " + str(Network.STEAM_USERNAME) + ", "
	$Control / Control / Panel / RichTextLabel3.bbcode_text = str(body)
	text_end.text = str(data["closing"]) + str(data["from"])
	
	var ib = $Control / Control / Panel / RichTextLabel4
	ib.text = ""
	if data.items.size() > 0:
		ib.text = "Gifts Included: \n"
		
		var index = 0
		var leftover = 0
		for i in data.items:
			ib.text = ib.text + str(Globals.item_data[i.id]["file"].item_name)
			if data.items.size() > index + 1: ib.text = ib.text + ", "
			index += 1
			if index > 6:
				leftover = data.items.size() - 6
				break
		if leftover > 0: ib.text = ib.text + "and " + str(leftover) + " more..."

func _on_Button_pressed():
	emit_signal("_finished")
	queue_free()

func _on_Button2_pressed():
	PlayerData._deny_letter(saved_data["letter_id"])
	emit_signal("_finished")
	queue_free()

func _on_Button3_pressed():
	PlayerData._accept_letter(saved_data["letter_id"])
	emit_signal("_finished")
	queue_free()
	
