extends TextureRect

export var unique = false
export var unique_scale = 1.0
export var unique_speed = 0.25

func _ready():
	if unique:
		material = material.duplicate()
		
		var size = clamp( - 3.5 + unique_scale, - 8.0, 3.5)
		material.set_shader_param("inset", size)

func _setup(item):
	var data = Globals.item_data[item["id"]]["file"]
	texture = data.icon
	var size = (item["size"] / data.average_size) * 3.5
	size = clamp( - 3.5 + size, - 8.0, 3.5)
	material.set_shader_param("inset", size)
	modulate = Color(1.0, 1.0, 1.0)

func _setup_nonitem(tex, blackout = false):
	texture = tex if not blackout else preload("res://Assets/Textures/questionmark.png")
	material.set_shader_param("inset", 0.0)
	modulate = Color(0.0, 0.0, 0.0) if blackout else Color(1.0, 1.0, 1.0)

func _physics_process(delta):
	var rotate = material.get_shader_param("y_rot")
	if not unique: rotate += 0.25
	else: rotate += unique_speed
	
	if rotate >= 180:
		rotate = - 180
	material.set_shader_param("y_rot", rotate)
