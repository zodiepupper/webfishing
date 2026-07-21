extends Node

var song_volumes = {
	"music1": - 2, 
	"music1_loop": - 2, 
	"music2": - 2, 
	"music3": - 2, 
	"floombo_fuibi": - 16, 
	"floombo_peinos": - 16, 
	"floombo_together": - 16, 
	"floombo_boxingglove": - 16, 
}

var song_playing = null

func _play_sound(id):
	get_node(id).play()

func _stop_sound(id):
	get_node(id).stop()

func _play_music(id, delay = 0.0):
	if delay > 0.0: yield(get_tree().create_timer(delay), "timeout")
	
	if song_playing:
		var tween = get_tree().create_tween()
		tween.tween_property(song_playing, "volume_db", linear2db(0.01), 2.0)
		tween.tween_callback(song_playing, "stop")
		song_playing = null
		tween.tween_callback(self, "_play_music", [id])
		return
	
	if not get_node(id): return
	
	song_playing = get_node(id)
	song_playing.volume_db = song_volumes[id]
	song_playing.play()

func _is_song_playing():
	if song_playing:
		return song_playing.playing
	else: return false
