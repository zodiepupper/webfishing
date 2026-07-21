extends Spatial

func _ready():
	for child in get_children():
		child.add_to_group("deep_spawn")
