extends Interactable

@export var shop_id = "rotated_shop"
@export var cam_offset: NodePath
@export var required_tag = ""

signal _open
signal _close

func _activate(actor):
	if required_tag != "" and not PlayerData.saved_tags.has(required_tag):
		PlayerData._send_notification("it doesn't seem to want to talk...", 1)
		return
	
	actor.hud.shop_id = shop_id
	actor.hud._change_menu(5)
	actor.cam_follow_node = get_node(cam_offset)
	actor.connect("_menu_closed", Callable(self, "_closed").bind(), CONNECT_ONE_SHOT)
	emit_signal("_open")

func _closed():
	emit_signal("_close")


