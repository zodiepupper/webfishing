extends ShopButton

func _setup():
	icon = preload("res://Assets/UI/stamina_bar4.png")

func _custom_update():
	cost = ceil((PlayerData.max_stamina * PlayerData.max_stamina) / 8.0)

func _custom_purchase():
	PlayerData.max_stamina += 2
