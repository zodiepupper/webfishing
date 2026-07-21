extends Spatial

onready var spawn_position = $spawn_position
onready var tutorial_spawn_position = $tutorial_spawn_position

func _set_zone(id):
	for child in $zones.get_children():
		child.visible = child.name == id

func _get_zone(id):
	for child in $zones.get_children():
		if child.name == id: return child
	return null

func _get_random_zone():
	randomize()
	return $zones.get_child(randi() % $zones.get_child_count())
