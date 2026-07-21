extends "res://Scenes/Entities/Props/prop.gd"

export var zone_name = "boat_raft_zone"
export var entrance_name = "boat_entrance"

func _ready():
	$transition_zone.zone_id = zone_name
	$transition_zone.zone_owner = owner_id
	$transition_zone.spawn_id = entrance_name
	$area_entrance.entrance_id = zone_name + "zone" + str(owner_id)
