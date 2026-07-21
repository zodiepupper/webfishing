extends Spatial

onready var voice_audio = preload("res://Scenes/Entities/Player/SpeechBubble/voice_audio.tscn")

func _play_sound(id, position = null, pitch = 1.0):
	if id == null: return
	var node = get_node_or_null(id)
	if not node: return
	if position: node.global_transform.origin = position
	if node.pitch_scale != pitch: node.pitch_scale = pitch
	node.play()





func _construct_voice(letter, voice, pitch):
	var new = voice_audio.instance()
	new.stream = Globals.voice_bank[voice][letter.to_upper()]
	new.pitch_scale = pitch
	add_child(new)
	new.play()
