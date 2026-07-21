extends PlayerProp

func _setup_not_controlled():
	$Interactable / CollisionShape.disabled = true
