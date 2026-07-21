extends Button

export var bait_id = ""
export (NodePath) var hudnode
export var header = ""
export (String, MULTILINE) var desc = ""

var selected = false

func _ready():
	var hd = "[color=#6a4420]" + header + "\n\n[/color]" + desc
	if not PlayerData.bait_unlocked.has(bait_id): hd = "[color=#6a4420]LOCKED\n\n[/color]BUY LICENSE TO UNLOCK"
	
	connect("mouse_entered", get_node(hudnode), "_bait_hover", [hd])
	PlayerData.connect("_bait_update", self, "_select")
	_select()

func _select():
	selected = PlayerData.bait_selected == bait_id
	if not PlayerData.bait_unlocked.has(bait_id): icon = PlayerData.BAIT_ICONS["locked"]
	else: icon = PlayerData.BAIT_ICONS[bait_id]
	
	$Panel.visible = selected
	$Label.text = "x" + str(PlayerData.bait_inv[bait_id])
	disabled = bait_id != "" and (PlayerData.bait_inv[bait_id] <= 0 or not PlayerData.bait_inv.has(bait_id))

func _on_bait_button_pressed():
	if not PlayerData.bait_inv.has(bait_id): return
	if PlayerData.bait_selected == bait_id:
		PlayerData.bait_selected = ""
	else:
		PlayerData.bait_selected = bait_id
	PlayerData.emit_signal("_bait_update")
