extends RichTextLabel

func _ready():
	PlayerData.connect("_item_equip", self, "_update")
	PlayerData.connect("_help_update", self, "_force_update")
	bbcode_text = ""

func _update(ref):
	var item = PlayerData._find_item_code(ref)
	var data = Globals.item_data[item.id]["file"]
	
	bbcode_text = "[right]" + data.help_text
	if data.help_text != "": bbcode_text = bbcode_text + " [img={valign}]res://Assets/Textures/UI/small_m1.png[/img]"

func _force_update(ntext):
	bbcode_text = "[right]" + ntext
	if ntext != "": bbcode_text = bbcode_text + " [img={valign}]res://Assets/Textures/UI/small_m1.png[/img]"
