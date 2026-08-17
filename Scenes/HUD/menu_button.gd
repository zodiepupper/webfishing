extends Control

@export var tab_num = 0
@export var y_offset = 0
@export var image: Texture2D
@export var header = ""
@export var desc = ""

var hovered = false
var highlighted = false

@onready var shadow = $shadow

signal _pressed

func _process(delta):
	var alt_color = Color(0.6, 0.6, 0.6) if not hovered else Color(0.7, 0.7, 0.7)
	modulate = alt_color if not highlighted else Color(1.0, 1.0, 1.0)
	
	var extra_y = 0 if not highlighted else - 8
	$TextureButton.position.y = lerp($TextureButton.position.y, y_offset + extra_y, 0.2)
	$TextureRect.position.y = $TextureButton.position.y - 3
	
	$TextureButton.offset_bottom = 61 + y_offset + extra_y
	$TextureButton.offset_top = 0 + y_offset + extra_y

func _update(current_slot):
	highlighted = current_slot == tab_num
	$TextureRect.visible = highlighted
	$TextureButton / TooltipNode.header = header
	$TextureButton / TooltipNode.body = desc
	
	$TextureButton.texture_normal = image
	$shadow.position.y = y_offset + 4

func _on_TextureButton_pressed():
	emit_signal("_pressed", tab_num)

func _on_TextureButton_mouse_entered(): hovered = true
func _on_TextureButton_mouse_exited(): hovered = false
