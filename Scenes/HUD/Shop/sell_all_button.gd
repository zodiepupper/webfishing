extends HBoxContainer

signal _sell_all

func _on_sell_all_pressed(): emit_signal("_sell_all")
