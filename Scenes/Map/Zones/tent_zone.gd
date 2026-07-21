extends Zone

onready var tent_object = preload("res://Scenes/Entities/Tent/tent_object.tscn")

func _tent_update(id, old_zone, old_id):
	$area_entrance.entrance_owner = id
	
	$transition_zone.zone_id = old_zone
	$transition_zone.spawn_id = "tent" + str(id)

func _tent_objects(new):
	for child in $objects.get_children(): child.queue_free()
	
	for object in new[0]:
		var data = Globals.item_data[object["id"]]["file"]
		if data.mesh:
			var m = tent_object.instance()
			m.mesh = data.mesh
			m.ref = object["ref"]
			$objects.add_child(m)
			m.global_transform.origin = object["pos"]
