extends Minigame

onready var item_icon = $Control / item

var chosen_item = 0

func _ready():
	GlobalAudio._play_sound("labeler_open")
	PlayerData.connect("_return_item_choice", self, "_update_item")
	item_icon._setup_item(0)

func _on_close_button_pressed():
	_end(true)

func _on_choose_item_pressed():
	PlayerData.emit_signal("_request_item_choice", [], 1, 1, "", false)

func _on_rename_button_pressed():
	if chosen_item == 0: return
	GlobalAudio._play_sound("labeler_close")
	PlayerData._rename_item(chosen_item, $Control / name.text)
	_end(true)

func _update_item(items):
	if items.size() <= 0: return
	var item = items[0]
	item_icon._setup_item(item)
	chosen_item = item

