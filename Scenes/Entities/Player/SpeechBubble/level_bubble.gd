extends CenterContainer

var time = 300

func _physics_process(delta):
	time -= 1
	
	if time <= 0 and $RichTextLabel.visible_characters <= 0: queue_free()

func _on_Timer_timeout():
	if time > 0:
		$RichTextLabel.visible_characters += 1
	elif $RichTextLabel.visible_characters > 0:
		$RichTextLabel.visible_characters -= 1
