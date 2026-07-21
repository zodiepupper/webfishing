extends Control

var clear_count = 0

signal _pressed
signal _clear_pressed

onready var label = $Button / HBoxContainer / Label
onready var ico = $Button / HBoxContainer / TextureRect

func _setup(slot):
	var save_data = UserSave._quick_open(slot)
	
	_update_reset()
	
	label.text = "Save Slot " + str(slot + 1)
	if save_data.empty():
		label.text = label.text + "\nEmpty Save"
		ico.visible = false
		$arrow.visible = false
		return
	
	var selected = UserSave.current_loaded_slot == slot
	var select_text = "" if not selected else " (SELECTED)"
	$arrow.visible = selected
	
	var fish_caught = save_data.fish_caught
	var color = Color("#ffeed5")
	if save_data.cosmetics_equipped.keys().has("primary_color"): color = Globals.cosmetic_data[save_data.cosmetics_equipped.primary_color]["file"].main_color
	
	label.text = label.text + select_text + "\n" + str(fish_caught) + " Fish Caught"
	ico.modulate = Color(color)

func _physics_process(delta):
	$arrow.modulate.a = 0.5 + (sin(OS.get_ticks_msec() * 0.01) * 0.25)

func _on_Button_pressed():
	emit_signal("_pressed")

func _on_reset_pressed():
	clear_count += 1
	if clear_count >= 10:
		clear_count = 0
		emit_signal("_clear_pressed")
	_update_reset()

func _update_reset():
	$reset.icon = null if clear_count > 0 else preload("res://Assets/Textures/UI/garbage_can.png")
	$reset / warning.text = "Clear in " + str(10 - clear_count)
	$reset / warning.visible = clear_count > 0
