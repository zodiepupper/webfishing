extends Control

var dead = 30
var index = 0
var bank = []
var shown = false

signal _finished

func _open(text = []):
	bank = text
	_open_index(0)
	yield(get_tree().create_timer(0.3), "timeout")
	shown = true

func _close():
	shown = false

func _open_index(i):
	if i >= bank.size():
		emit_signal("_finished")
		return
	
	dead = 30
	index = i
	$Panel / RichTextLabel.visible_characters = 0
	$Panel / RichTextLabel.bbcode_text = bank[i]

func _physics_process(delta):
	modulate.a = lerp(modulate.a, float(shown), 0.2)
	visible = modulate.a > 0.02
	
	dead -= 1
	if Input.is_action_just_pressed("primary_action") and dead <= 0 and shown:
		if $Panel / RichTextLabel.visible_characters < $Panel / RichTextLabel.bbcode_text.length():
			$Panel / RichTextLabel.visible_characters = $Panel / RichTextLabel.bbcode_text.length()
			dead = 15
		else:
			_open_index(index + 1)

func _on_Timer_timeout():
	$Panel / RichTextLabel.visible_characters += 1
