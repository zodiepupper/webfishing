extends Zone

@export var zone_name = ""

func _zone_update(id, old_zone, old_id):
	$area_entrance.entrance_owner = id
	$transition_zone.zone_id = old_zone
	$transition_zone.spawn_id = zone_name + "zone" + str(id)
