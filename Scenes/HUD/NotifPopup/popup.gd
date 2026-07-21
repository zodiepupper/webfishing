extends Control

func _setup(text, type):
	$RichTextLabel.text = text
	
	match type:
		0: $RichTextLabel / Panel.set("custom_styles/panel", preload("res://Assets/Themes/panel_green.tres"))
		1: $RichTextLabel / Panel.set("custom_styles/panel", preload("res://Assets/Themes/panel_red.tres"))

func _ready():
	$AnimationPlayer.play("play")

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
