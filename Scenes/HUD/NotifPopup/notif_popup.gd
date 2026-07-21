extends CanvasLayer

func _ready():
	PlayerData.connect("_notif_send", self, "_create_popup")

func _create_popup(text, type):
	var popup = preload("res://Scenes/HUD/NotifPopup/popup.tscn").instance()
	$Control / VBoxContainer.add_child(popup)
	popup._setup(text, type)
