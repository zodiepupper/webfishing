extends Panel

func _ready():
	PlayerData.connect("_bait_update", self, "_update")
	_update()

func _update():
	$AnimationPlayer.play("update")
	
	var bait = PlayerData.bait_selected
	$HBoxContainer / TextureRect.texture = PlayerData.BAIT_DATA[bait].icon
	$HBoxContainer / Label.text = "x" + str(PlayerData.bait_inv[bait])
	if bait == "": $HBoxContainer / Label.text = ""
