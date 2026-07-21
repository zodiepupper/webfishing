extends Actor

func _ready():
	$AnimationPlayer.play("intro")
	$transition_zone.zone_owner = owner_id
	$area_entrance.entrance_id = "tent" + str(owner_id)
