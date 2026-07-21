extends Button

var string = 0
var fret = 0

var notes = ["E", "F", "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D", "D#"]

func _set_marker(_s, _f):
	if string != _s: return
	
	$TextureRect.visible = string == _s and fret == _f
	
	var note = [0, 5, 10, 3, 7, 0][_s] + _f
	while note >= 12: note -= 12
	
	$TextureRect / Label.text = notes[note]
