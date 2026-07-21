extends Spatial

var emoting = false

var set_eye
var set_mouth
var alt_blink
var alt_eye
var temp_eye
var temp_mouth
var talk_mouth

var eye_mirror = true
var eye_blink = true

var blink_time = 0
var blink_amount = 0
var emote_time = 0
var reset_time = 60
var used_mouths = []

onready var blink_texture = preload("res://Assets/Textures/Face/eyes_base2.png")

func _physics_process(delta):
	if reset_time > 0:
		reset_time -= 1
		if reset_time <= 0:
			talk_mouth = null
			_update_mouth()
	
	if blink_time > 0:
		blink_time -= 1
		if blink_time <= 0:
			blink_amount -= 1
			_update_eyes()
	
	if emote_time > 0:
		emote_time -= 1
		if emote_time <= 0:
			temp_eye = null
			temp_mouth = null
			
			_update_eyes()
			_update_mouth()

func _update_eyes():
	var eye = set_eye
	var allow_alt_eye = true
	
	if temp_eye:
		eye = temp_eye
		allow_alt_eye = false
	if blink_time > 0:
		eye = blink_texture if not alt_blink else alt_blink
		allow_alt_eye = false
	
	if eye == set_eye:
		$eye_l.flip_h = eye_mirror
	else:
		$eye_l.flip_h = true
	
	$eye_l.texture = eye
	$eye_r.texture = eye if not (allow_alt_eye and alt_eye) else alt_eye

func _update_mouth():
	var mouth = set_mouth
	if temp_mouth: mouth = temp_mouth
	if talk_mouth: mouth = talk_mouth
	$mouth_l.texture = mouth
	$mouth_r.texture = mouth

func _setup_face(data):
	match data["species"]:
		"species_cat": $AnimationPlayer.play("cat_face")
		"species_dog": $AnimationPlayer.play("dog_face")
	
	if data["eye"] != "":
		var eye = Globals.cosmetic_data[data["eye"]]["file"]
		set_eye = eye.icon
		alt_eye = eye.alt_eye
		alt_blink = eye.alt_blink
		eye_mirror = eye.mirror_face
		eye_blink = eye.allow_blink
	
	if data["nose"] != "":
		var nose = Globals.cosmetic_data[data["nose"]]["file"]
		$nose.texture = nose.icon
	
	if data["mouth"] != "":
		var mouth = Globals.cosmetic_data[data["mouth"]]["file"]
		set_mouth = mouth.icon
	
	_update_eyes()
	_update_mouth()

func _on_blink_timer_timeout():
	$blink_timer.wait_time = rand_range(2.0, 10.0)
	if not eye_blink: return
	
	var double = false
	if randf() < 0.15:
		double = true
		$blink_timer.wait_time = 0.2
	
	$blink_timer.start()
	
	if emoting: return
	
	blink_time = 15 if not double else 6
	_update_eyes()

func _emote(emotion, duration):
	var eye
	var mouth
	
	match emotion:
		"love":
			eye = preload("res://Assets/Textures/Face/eyes_base9.png")
		"happy":
			eye = preload("res://Assets/Textures/Face/eyes_base5.png")
			mouth = preload("res://Assets/Textures/Face/mouth_base3.png")
		"angry":
			eye = preload("res://Assets/Textures/Face/eyes_base8.png")
			mouth = preload("res://Assets/Textures/Face/mouth_base6.png")
		"sad":
			eye = preload("res://Assets/Textures/Face/eyes_base21.png")
			mouth = preload("res://Assets/Textures/Face/mouth_base5.png")
		"surprised":
			eye = preload("res://Assets/Textures/Face/eyes_base10.png")
			mouth = preload("res://Assets/Textures/Face/mouth_base19.png")
		"cat":
			mouth = preload("res://Assets/Textures/Face/mouth_base20.png")
		"flat":
			mouth = preload("res://Assets/Textures/Face/mouth_base7.png")
		"strum":
			eye = preload("res://Assets/Textures/Face/eyes_base2.png")
		"bark":
			duration = 0.5
			eye = null
			mouth = preload("res://Assets/Textures/Face/mouth_base3.png")
		"growl":
			duration = 0.5
			eye = null
			mouth = preload("res://Assets/Textures/Face/mouth_base28.png")
		"whine":
			duration = 0.5
			eye = null
			mouth = preload("res://Assets/Textures/Face/mouth_base6.png")
		"bark_ready":
			eye = preload("res://Assets/Textures/Face/eyes_base5.png")
		"kiss":
			eye = preload("res://Assets/Textures/Face/eyes_base5.png")
			mouth = preload("res://Assets/Textures/Face/mouth_base29.png")
			duration = 1.0
		"punch":
			eye = preload("res://Assets/Textures/Face/eyes_base5.png")
			duration = 1.0
	
	temp_eye = eye
	temp_mouth = mouth
	emote_time = duration * 60.0
	_update_eyes()
	_update_mouth()

func _talk():
	if used_mouths == []:
		used_mouths = [preload("res://Assets/Textures/Face/mouth_base3.png"), preload("res://Assets/Textures/Face/mouth_base2.png"), null]
	var frame = randi() % used_mouths.size()
	
	talk_mouth = used_mouths[frame]
	used_mouths.remove(frame)
	reset_time = 15
	_update_mouth()

func _show_blush(show):
	$blush.visible = show
