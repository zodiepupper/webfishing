extends PlayerProp

var state = - 1
var listening = false

onready var audio = $AudioStreamPlayer3D

func _ready():
	custom_valid_actions = ["_set_state"]
	
	if not controlled:
		$Interactable.text = "LISTEN IN"
		audio.unit_db = linear2db(0.0)

func _sync_add_state():
	var new_state = state + 1
	if new_state > 4: new_state = - 1
	_set_state(new_state)
	Network._send_actor_action(actor_id, "_set_state", [new_state], true)

func _set_state(new):
	state = new
	
	if controlled:
		if state == - 1: $Interactable.text = "TURN ON"
		elif state != 4: $Interactable.text = "NEXT SONG"
		else: $Interactable.text = "TURN OFF"
		audio.unit_db = 0.0
	
	match state:
		- 1:
			audio.playing = false
		0:
			audio.stream = preload("res://Sounds/Fluffing a Duck.mp3")
			audio.playing = true
		1:
			audio.stream = preload("res://Sounds/Carefree.mp3")
			audio.playing = true
		2:
			audio.stream = preload("res://Sounds/Heartbreaking.mp3")
			audio.playing = true
		3:
			audio.stream = preload("res://Sounds/Sneaky Snitch.mp3")
			audio.playing = true
		4:
			audio.stream = preload("res://Sounds/Meatball Parade.mp3")
			audio.playing = true

func _on_Interactable__activated():
	if controlled:
		_sync_add_state()
	else:
		_toggle_listening()

func _toggle_listening():
	listening = not listening
	if listening:
		audio.unit_db = linear2db(1.0)
	else:
		audio.unit_db = linear2db(0.0)
	
	if listening:
		$Interactable.text = "STOP LISTENING"
	else:
		$Interactable.text = "LISTEN IN"
