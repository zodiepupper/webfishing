extends CanvasLayer

var panel_offset = Vector2(16, 12)

var hovered_tooltip = null

var current_header = ""
var current_body = ""
var current_node = null

@onready var panel = $Panel
@onready var header = $Panel / header
@onready var body = $Panel / body

func _ready():
	_update("", "", null)
	panel.hide()

func _process(delta):
	var screen_offset = Vector2()
	var screen_size = get_viewport().get_visible_rect().size
	if ($mouse_ref.get_local_mouse_position() + panel_offset + panel.size).x > screen_size.x:
		screen_offset.x = - panel.size.x
	if ($mouse_ref.get_local_mouse_position() + panel_offset + panel.size).y > screen_size.y:
		screen_offset.y = - panel.size.y
	
	panel.position = $mouse_ref.get_local_mouse_position() + panel_offset + screen_offset
	if hovered_tooltip != null:
		if not is_instance_valid(hovered_tooltip) or not hovered_tooltip.is_visible_in_tree():
			_hover_exit(hovered_tooltip)

func _hover_enter(node):
	hovered_tooltip = node
	if hovered_tooltip.header != "!no_text!":
		_update(hovered_tooltip.header, hovered_tooltip.body, hovered_tooltip.node)
		panel.show()
	else:
		panel.hide()

func _hover_exit(node):
	if hovered_tooltip == node:
		hovered_tooltip = null
		panel.hide()

func _update(_header, _body, node):
	current_header = _header
	
	
	var final_body = ""
	var split = _body.split(" ")
	for s in split:
		var add = s + " "
		if s.begins_with("$$"):
			var action = s.substr(2, - 1)
			add = "[" + InputMap.action_get_events(action)[0].as_text() + "]"
		final_body = final_body + add
	
	current_body = final_body
	current_node = node
	
	_update_visible()

func _update_visible():
	header.text = current_header
	body.text = current_body
	
	var longest = 0
	for line in body.text.split("\n"):
		if line.length() > longest: longest = line.length()
	if header.text.length() > longest: longest = header.text.length()
	
	panel.size.x = clamp(longest * 64, 84, 512)
	body.size.x = panel.size.x - 16
	
	await get_tree().process_frame
	panel.size.y = 0
	panel.size.y = body.size.y + 64
