extends Interactable

func _activate(actor):
	actor._sync_sfx("boat_horn", global_transform.origin)
