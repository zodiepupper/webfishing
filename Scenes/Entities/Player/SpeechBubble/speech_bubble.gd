extends Control

var final_text = ""
var buffer = 0
var speed = 0.05

signal _letter_said(letter)

func _ready():
	
	
	
	
	
	var text_split = final_text.split(" ")
	var final_real = ""
	var count = 0
	var index = 0
	for split in text_split:
		var end = text_split.size() - 1 == index
		
		if count + split.length() > 35:
			
			var s = (count + split.length()) - 35
			split = split.insert(s, "-\n")
			
			count = 0
		
		final_real = final_real + split
		if not end: final_real = final_real + " "
		
		count += split.length()
		if count > 30 and not end:
			final_real = final_real + "\n"
			count = 0
		
		index += 1
	
	final_text = final_real
	
	$RichTextLabel.visible_characters = 0
	$RichTextLabel.text = final_text
	
	$Timer.wait_time = speed / 100.0
	$Timer.start()

func _on_Timer_timeout():
	$RichTextLabel.visible_characters += 1
	
	if $RichTextLabel.visible_characters <= $RichTextLabel.text.length():
		var letter = $RichTextLabel.text[$RichTextLabel.visible_characters - 1]
		emit_signal("_letter_said", letter)
	else:
		$Timer.wait_time = 0.06
	
	buffer += 1
	var timeout = max(final_text.length() * 2.5, 52)
	
	if buffer >= timeout:
		queue_free()
