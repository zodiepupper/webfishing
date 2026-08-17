extends RichTextLabel

func _ready():
	PlayerData.connect("_item_equip", Callable(self, "_update"))
	PlayerData.connect("_help_update", Callable(self, "_force_update"))
	text = ""

func _update(ref):
	var item = PlayerData._find_item_code(ref)
	var data = Globals.item_data[item.id]["file"]
	
	text = "[right]" + data.help_text
	if data.help_text != "": text = text + " [img={valign}]res://Assets/Textures/UI/small_m1.png[/img]"

func _force_update(ntext):
	text = "[right]" + ntext
	if ntext != "": text = text + " [img={valign}]res://Assets/Textures/UI/small_m1.png[/img]"
