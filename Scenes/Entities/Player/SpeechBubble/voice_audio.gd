extends AudioStreamPlayer3D

func _on_voice_audio_finished(): queue_free()
