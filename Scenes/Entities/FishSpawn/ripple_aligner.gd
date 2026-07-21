extends Spatial

func _ready():
	var index = 0
	for child in get_children():
		child.frame = index
		child.playing = true
		index += 5
