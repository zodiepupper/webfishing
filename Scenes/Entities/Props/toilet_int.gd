extends Interactable

func _activate(actor):
	if not actor.controlled: return
	get_parent()._sync_flush()
