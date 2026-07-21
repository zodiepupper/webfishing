extends AudioStreamPlayer3D

var fret_intervals = 7.38
var end_point = 0.0
var current_fret = 0

var sound_array = []
var sound_blacklist = []

func _ready():
	for i in 4:
		var new = AudioStreamPlayer3D.new()
		new.stream = stream
		new.unit_db = - 20
		new.unit_size = 80
		new.max_db = - INF
		new.max_distance = 150
		new.bus = bus
		new.attenuation_filter_cutoff_hz = 8000
		
		add_child(new)
		sound_array.append(new)
		
		
		
		
		
		

func _play_fret(fret, hammer = false, volume = 1.0):
	fret = fret + 1
	end_point = ((fret + 1) * fret_intervals) - 0.01
	
	var point = (fret * fret_intervals) + 0.01
	_play_at_point(point, fret, hammer, volume)
	
	current_fret = fret

func _hammer_fret(fret):
	if current_fret == (fret + 1) or fret == - 1: return
	_play_fret(fret, true)

func _play_at_point(point, fret, hammer_fret, volume):
	var found_node = false
	var index = 0
	
	if hammer_fret:
		if fret == current_fret: return
		for node in sound_array:
			if node.max_db != - INF:
				var seek_distance = ((fret - current_fret) * fret_intervals) - 0.01
				var rew_cap = (fret * fret_intervals)
				seek_distance -= 0.5
				
				point = clamp(node.get_playback_position() + seek_distance, rew_cap, end_point)
	
	for node in sound_array:
		if node.max_db != - INF:
			node.call_deferred("set", "max_db", linear2db(0.0))
		elif node.max_db == - INF and not found_node and not sound_blacklist.has(node):
			found_node = true
			node.seek(0.0)
			node.max_db = linear2db(volume * 0.32)
			node.play(point)
			sound_blacklist.append(node)
			print("NODE TO PLAY IS: ", node, " W VOLUME ", node.max_db, " AT POINT ", point)
		elif sound_blacklist.has(node):
			sound_blacklist.erase(node)
		
		index += 1
	
	var pl = []
	for node in sound_array: pl.append(str(node.playing) + " / " + str(node.max_db))

func _physics_process(delta):
	_call()

func _call():
	for sound in sound_array:
		if sound.playing and sound.get_playback_position() >= (end_point - 0.02) and sound.max_db != - INF:
			sound.playing = false
