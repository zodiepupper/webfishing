extends Control

onready var box = $Panel / VBoxContainer

func _ready():
	if UserSave.last_loaded_slot == - 1:
		_open()
	else:
		_close()

func _open():
	visible = true
	_refresh()

func _close():
	visible = false

func _refresh():
	for child in box.get_children(): child.queue_free()
	
	for i in 4:
		var save_slot = preload("res://Scenes/Menus/Main Menu/SaveSelect/save_select.tscn").instance()
		box.add_child(save_slot)
		save_slot._setup(i)
		save_slot.connect("_pressed", self, "_save_selected", [i])
		save_slot.connect("_clear_pressed", self, "_reset_selected", [i])

func _save_selected(slot):
	UserSave._quick_save()
	UserSave._load_save(slot)
	_close()

func _reset_selected(slot):
	UserSave._reset_save_slot(slot)
	_close()

func _on_save_select_button_pressed():
	_open()

func _on_close_pressed():
	if UserSave.current_loaded_slot == - 1:
		UserSave._load_save(0)
	_close()
