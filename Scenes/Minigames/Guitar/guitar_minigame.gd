extends Minigame

onready var neck = $fret_main / neck

var string_frets = [0, 0, 0, 0, 0, 0]

var selected_shape = 0
var saved_shapes = [
	[0, 0, 0, 0, 0, 0], 
	[0, 0, 0, 0, 0, 0], 
	[0, 0, 0, 0, 0, 0], 
	[0, 0, 0, 0, 0, 0], 
	[0, 0, 0, 0, 0, 0], 
	[0, 0, 0, 0, 0, 0], 
	[0, 0, 0, 0, 0, 0], 
	[0, 0, 0, 0, 0, 0], 
	[0, 0, 0, 0, 0, 0], 
]
var selected_shape_page = 0

signal _fret_update(string, fret)

func _ready():
	saved_shapes = PlayerData.guitar_shapes.duplicate(true)
	_setup_guitar()
	_select_shape(0)
	_select_shape_page(0)
	
	$fret_main.rect_size = Vector2(1920, 1080)
	$ColorRect.rect_size = Vector2(1920, 1080)
	
	$AnimationPlayer.play("intro")

func _process(delta):
	if not Input.is_action_pressed("move_sneak"):
		if Input.is_action_just_pressed("bind_1"): _select_shape(0)
		if Input.is_action_just_pressed("bind_2"): _select_shape(1)
		if Input.is_action_just_pressed("bind_3"): _select_shape(2)
		if Input.is_action_just_pressed("bind_4"): _select_shape(3)
		if Input.is_action_just_pressed("bind_5"): _select_shape(4)
		if Input.is_action_just_pressed("bind_6"): _select_shape(5)
		if Input.is_action_just_pressed("bind_7"): _select_shape(6)
		if Input.is_action_just_pressed("bind_8"): _select_shape(7)
		if Input.is_action_just_pressed("bind_9"): _select_shape(8)
	else:
		if Input.is_action_just_pressed("bind_1"): _select_shape_page(0)
		if Input.is_action_just_pressed("bind_2"): _select_shape_page(1)
		if Input.is_action_just_pressed("bind_3"): _select_shape_page(2)
		if Input.is_action_just_pressed("bind_4"): _select_shape_page(3)
		if Input.is_action_just_pressed("bind_5"): _select_shape_page(4)
		if Input.is_action_just_pressed("bind_6"): _select_shape_page(5)
	
	if Input.is_action_just_pressed("guitar_string_1"): _strum_string(0.0, 0)
	if Input.is_action_just_pressed("guitar_string_2"): _strum_string(0.0, 1)
	if Input.is_action_just_pressed("guitar_string_3"): _strum_string(0.0, 2)
	if Input.is_action_just_pressed("guitar_string_4"): _strum_string(0.0, 3)
	if Input.is_action_just_pressed("guitar_string_5"): _strum_string(0.0, 4)
	if Input.is_action_just_pressed("guitar_string_6"): _strum_string(0.0, 5)

func _setup_guitar():
	for fret in 16:
		var hbox = preload("res://Scenes/Minigames/Guitar/fret_container.tscn").instance()
		neck.add_child(hbox)
		
		var sep = preload("res://Scenes/Minigames/Guitar/fret_texture.tscn").instance()
		neck.add_child(sep)
		
		for s in 6:
			var button = preload("res://Scenes/Minigames/Guitar/fret_button.tscn").instance()
			button.fret = fret
			button.string = s
			connect("_fret_update", button, "_set_marker")
			button.connect("pressed", self, "_select_fret", [s, fret])
			hbox.add_child(button)
	
	var index = 0
	for string in $strings_main / strings.get_children():
		string.connect("_pluck", self, "_strum_string", [index])
		index += 1
	
	index = 0
	for i in $"%shapes".get_children():
		i.text = str(index + 1)
		i.connect("pressed", self, "_select_shape", [index])
		index += 1
	
	index = 0
	for i in $fret_main / capos.get_children():
		i.connect("pressed", self, "_set_capo", [index])
		index += 1
	
	index = 0
	for i in $"%tabs".get_children():
		i.connect("pressed", self, "_select_shape_page", [index])
		index += 1

func _select_shape_page(page):
	selected_shape_page = page
	_select_shape(selected_shape)
	
	var index = 0
	for i in $"%tabs".get_children():
		i.disabled = index == page
		index += 1

func _select_shape(shape):
	selected_shape = shape
	
	for i in 6:
		var shape_data = saved_shapes[selected_shape_page][shape][i]
		_select_fret(i, shape_data, true)
	
	var index = 0
	for i in $"%shapes".get_children():
		i.disabled = index == shape
		index += 1
	
	if Input.is_action_pressed("move_sprint"):
		for i in 6:
			PlayerData.emit_signal("_hammer_guitar", i, string_frets[i])

func _select_fret(string, fret, ignore_overwrite = false):
	if string_frets[string] == fret and not ignore_overwrite:
		fret = - 1
	
	emit_signal("_fret_update", string, fret)
	string_frets[string] = fret
	saved_shapes[selected_shape_page][selected_shape][string] = fret

func _strum_string(volume, string):
	if string_frets[string] == - 1: return
	$strings_main / strings.get_child(string).wobble = 9.0
	PlayerData.emit_signal("_play_guitar", string, string_frets[string], (1.0 - volume))

func _on_Button_pressed():
	PlayerData.guitar_shapes = saved_shapes.duplicate(true)
	_end(true)

func _set_capo(fret):
	for i in 6: _select_fret(i, fret, true)
