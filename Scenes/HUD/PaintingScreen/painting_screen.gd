extends Minigame

enum BrushMode{
	PENCIL, 
	ERASER, 
}
const COLORS = ["#101c31", "#ac0029", "#a4aa39", "#008583", "#e69d00"]

var brush_data_list: Array = []

var is_mouse_in_drawing_area: = false
var last_mouse_pos = Vector2()
var mouse_click_start_pos = Vector2.INF

var brush_mode = BrushMode.PENCIL
var brush_size = 6
var step_size = 2
var brush_color = Color("#101c31")

var canvas_size = 128

var bg_color = Color("#ffeed5")

var image: Image = null
var texture: ImageTexture = null

onready var drawing_zone = $Control / Panel / TextureRect
onready var colors = $Control / Panel / HBoxContainer3

func _ready():
	_setup_colors()
	_reset_image()

func _setup_colors():
	var index = 0
	for color in COLORS:
		colors.get_child(index).connect("pressed", self, "_change_color", [color])
		index += 1
	brush_color = COLORS[0]





func _on_create_drawing_pressed():
	image.lock()
	
	var test = image.get_data()
	
	var new = Image.new()
	new.create_from_data(canvas_size, canvas_size, false, Globals.IMAGE_FORMAT, test)
	
	var textur = ImageTexture.new()
	textur.create_from_image(new)
	
	$Control / TextureRect2.texture = textur
	
	var painting_name = "My Unnamed Painting"
	if $Control / Panel / LineEdit.text != "": painting_name = $Control / Panel / LineEdit.text
	
	var new_data = Marshalls.raw_to_base64(image.get_data())
	
	
	print(new_data.length())

func _on_close_pressed():
	_end(true)





func _reset_image():
	image = Image.new()
	image.create(canvas_size, canvas_size, false, Globals.IMAGE_FORMAT)
	image.lock()
	for x in canvas_size:
		for y in canvas_size:
			image.set_pixel(x, y, bg_color)
	image.unlock()
	
	texture = ImageTexture.new()
	$Control / Panel / TextureRect.texture = texture
	
	_update_texture()

func _process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	
	var drawing_area_rect = Rect2(drawing_zone.rect_position, drawing_zone.rect_size)
	is_mouse_in_drawing_area = drawing_area_rect.has_point(mouse_pos)
	
	if Input.is_action_pressed("primary_action"):
		if mouse_click_start_pos.is_equal_approx(Vector2.INF):
			mouse_click_start_pos = mouse_pos
		
		if _check_if_mouse_is_inside_canvas():
			_add_brush(mouse_pos, brush_mode, last_mouse_pos)
	else:
		mouse_click_start_pos = Vector2.INF
	
	last_mouse_pos = mouse_pos

func _check_if_mouse_is_inside_canvas() -> bool:
	if mouse_click_start_pos != null:
		if Rect2(drawing_zone.rect_position, drawing_zone.rect_size).has_point(mouse_click_start_pos):
			if is_mouse_in_drawing_area: return true
	return false

func _add_brush(mouse_pos, type, from):
	var color = brush_color
	if type == BrushMode.ERASER: color = bg_color
	
	
	var scale = drawing_zone.rect_size / canvas_size
	mouse_pos = (mouse_pos - drawing_zone.rect_global_position) / scale
	from = (from - drawing_zone.rect_global_position) / scale
	
	var steps = 1 + floor(from.distance_to(mouse_pos) / step_size)
	for s in steps:
		var step = (s * step_size) * (from - mouse_pos).normalized()
		
		var pos = mouse_pos + step
		pos.x = clamp(pos.x, 0, canvas_size - 1)
		pos.y = clamp(pos.y, 0, canvas_size - 1)
		
		image.lock()
		
		var mid = floor(brush_size / 2.0)
		for x in brush_size:
			for y in brush_size:
				image.set_pixel(pos.x + x - mid, pos.y + y - mid, color)
		
		image.unlock()
	
	_update_texture()

func _update_texture():
	var sent = image.duplicate(true)
	texture.create_from_image(sent, not Texture.FLAG_FILTER)

func _on_Button_pressed():
	brush_mode = BrushMode.PENCIL
func _on_Button2_pressed():
	brush_mode = BrushMode.ERASER

func _change_color(color):
	brush_color = color

func _brush_size(size):
	brush_size = [2, 6, 16][size]

func _on_clear_pressed():
	_reset_image()
