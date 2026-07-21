extends Button

export var force_hotkey = - 1
export var dim_when_unequipped = false
export var refresh_on_resize = false

var slot = 0
var highlighted = false
var hotkey = - 1
var new_ref = 0
var saved_ref = 0
var last_equipped = 0

onready var hotkey_node = $root / Panel / hotkey
onready var hotkey_panel = $root / Panel
onready var star = $root / locked

signal _right_click

func _ready():
	_highlight(false)
	PlayerData.connect("_hotbar_refresh", self, "_update")
	PlayerData.connect("_inventory_refresh", self, "_update")
	PlayerData.connect("_item_equip", self, "_equip_update")
	if refresh_on_resize: get_tree().get_root().connect("size_changed", self, "_equip_refresh")

func _setup_item(ref):
	saved_ref = ref
	_update()

func _update():
	var ref = saved_ref
	var idata = PlayerData._find_item_code(ref)
	var id = idata["id"]
	
	if not Globals.item_data.keys().has(id): return
	var data = Globals.item_data[id]["file"]
	$root / TextureRect.texture = data.icon
	$root / tooltip_node.header = "[color=#6a4420]" + PlayerData._get_item_name(ref) + "[/color]"
	
	var sizetext = "\n" + str(idata["size"]) + " cm" if idata["size"] < 100.0 else "\n" + str(idata["size"] / 100.0) + " m"
	if not data.uses_size: sizetext = ""
	
	var worthtext = "\n[color=#a4aa39]Worth $" + str(PlayerData._get_item_worth(ref)) + "[/color]"
	if not data.can_be_sold: worthtext = ""
	
	var desc = "[color=#b48141]" + data.item_description + "[/color]"
	if force_hotkey == - 1: desc = desc + "\n[color=#b48141](Press 1-5 to equip to hotbar)[/color]"
	
	var favorited = PlayerData.locked_refs.has(ref)
	star.visible = favorited
	if not favorited: desc = desc + "\n[color=#b48141](Right-Click to favorite item.)[/color]"
	else: desc = desc + "\n[color=#b48141](Right-Click to unfavorite item.)[/color]"
	
	$root / tooltip_node.body = desc + sizetext + worthtext
	
	var mat = $root / quality.get("custom_styles/panel")
	mat.border_color = PlayerData.QUALITY_DATA[idata["quality"]].color
	$root / quality.visible = idata["quality"] > 0
	
	
	var count = 0
	if idata.keys().has("count"):
		count = idata["count"]
	$root / stack_count.text = "x" + str(count)
	$root / stack_count.visible = count > 1
	
	hotkey = []
	for slot in PlayerData.hotbar.keys():
		if PlayerData.hotbar[slot] == ref:
			hotkey.append(slot + 1)
	
	if force_hotkey != - 1: hotkey = [force_hotkey]
	
	if hotkey.size() > 1: hotkey_node.text = "*"
	elif hotkey.size() > 0: hotkey_node.text = str(hotkey[0])
	else: hotkey_node.text = ""
	
	hotkey_panel.visible = hotkey.size() > 0

func _equip_update(ref):
	new_ref = ref
	last_equipped = ref
	if saved_ref == 0: new_ref = - 1
	_equip_refresh()

func _equip_refresh():
	yield(get_tree(), "idle_frame")
	$root / ColorRect.visible = saved_ref == new_ref
	var t = 0.9 if dim_when_unequipped and saved_ref != new_ref else 1.0
	rect_scale.x = 0.8 if dim_when_unequipped and saved_ref != new_ref else 1.0
	rect_scale.y = 0.8 if dim_when_unequipped and saved_ref != new_ref else 1.0

func _highlight(toggle):
	$root / ColorRect.visible = toggle
	highlighted = toggle

func _on_item_visibility_changed():
	call_deferred("_equip_update", last_equipped)

func _on_right_mouse_pressed():
	emit_signal("_right_click")
	_update()
