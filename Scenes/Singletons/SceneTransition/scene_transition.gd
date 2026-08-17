extends CanvasLayer

var locked = false

signal _finished

func _ready():
	$AnimationPlayer.play_backwards("Out")

func _change_scene(to, delay = 0.3, show_intro = true, show_outro = true):
	if locked:
		push_error("ATTEMPTED SCENE CHANGE WHILE LOCKED")
		return
	locked = true
	
	OptionsMenu.fade_audio_des = 0.0
	
	if show_intro:
		$AnimationPlayer.play("Out")
		GlobalAudio._play_sound("guitar_in")
		await $AnimationPlayer.animation_finished
	else:
		$Control.material.set_shader_parameter("circle_size", 0.0)
	
	if delay > 0.0: await get_tree().create_timer(delay).timeout
	
	emit_signal("_finished")
	get_tree().change_scene_to_file(to)
	
	if delay > 0.0: await get_tree().create_timer(0.1).timeout
	
	OptionsMenu.fade_audio_des = 1.0
	
	if show_outro:
		GlobalAudio._play_sound("guitar_out")
		$AnimationPlayer.play_backwards("Out")
	else:
		$AnimationPlayer.play("RESET")
	
	locked = false

func _fake_scene_change(delay = 0.3):
	$AnimationPlayer.play("Out")
	OptionsMenu.fade_audio_des = 0.0
	GlobalAudio._play_sound("guitar_in")
	await $AnimationPlayer.animation_finished
	await get_tree().create_timer(delay).timeout
	emit_signal("_finished")
	GlobalAudio._stop_sound("guitar_in")
	GlobalAudio._play_sound("guitar_out")
	$AnimationPlayer.play_backwards("Out")
	OptionsMenu.fade_audio_des = 1.0
	
