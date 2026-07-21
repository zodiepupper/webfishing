extends CanvasLayer

signal _choice_made(accepted)
signal _closed

func _ready():
	visible = false

func _show_popup(text, delay = 0.0, choices = false):
	if delay > 0.0: yield(get_tree().create_timer(delay), "timeout")
	
	$Control / Panel / Label.text = text
	$Control / Panel / Label.visible = not choices
	$Control / Panel / alt_Label.text = text
	$Control / Panel / alt_Label.visible = choices
	$Control / Panel / choices.visible = choices
	
	visible = true

func _on_Button_pressed():
	visible = false
	emit_signal("_closed")

func _on_accept_choice_pressed():
	visible = false
	emit_signal("_choice_made", true)

func _on_deny_choice_pressed():
	visible = false
	emit_signal("_choice_made", false)
