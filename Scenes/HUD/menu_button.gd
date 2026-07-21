extends Control

export var tab_num = 0
export var y_offset = 0
export (Texture) var image
export var header = ""
export var desc = ""

var hovered = false
var highlighted = false

onready var shadow = $shadow

signal _pressed

func _process(delta):
	var alt_color = Color(0.6, 0.6, 0.6) if not hovered else Color(0.7, 0.7, 0.7)
	modulate = alt_color if not highlighted else Color(1.0, 1.0, 1.0)
	
	var extra_y = 0 if not highlighted else - 8
	$TextureButton.rect_position.y = lerp($TextureButton.rect_position.y, y_offset + extra_y, 0.2)
	$TextureRect.rect_position.y = $TextureButton.rect_position.y - 3
	
	$TextureButton.margin_bottom = 61 + y_offset + extra_y
	$TextureButton.margin_top = 0 + y_offset + extra_y

func _update(current_slot):
	highlighted = current_slot == tab_num
	$TextureRect.visible = highlighted
	$TextureButton / TooltipNode.header = header
	$TextureButton / TooltipNode.body = desc
	
	$TextureButton.texture_normal = image
	$shadow.rect_position.y = y_offset + 4

func _on_TextureButton_pressed():
	emit_signal("_pressed", tab_num)

func _on_TextureButton_mouse_entered(): hovered = true
func _on_TextureButton_mouse_exited(): hovered = false
