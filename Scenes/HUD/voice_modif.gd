extends Control

onready var p_slider = $HBoxContainer / HSlider
onready var s_slider = $HBoxContainer2 / speed

func _ready():
	p_slider.min_value = 0.7
	p_slider.max_value = 2.5
	p_slider.step = 0.1
	
	s_slider.min_value = 1
	s_slider.max_value = 12
	s_slider.step = 1
	
	p_slider.value = PlayerData.voice_pitch
	s_slider.value = PlayerData.voice_speed
	_pitch_change(PlayerData.voice_pitch)
	_speed_change(PlayerData.voice_speed)
	
	p_slider.connect("value_changed", self, "_pitch_change")
	s_slider.connect("value_changed", self, "_speed_change")

func _pitch_change(new):
	PlayerData.voice_pitch = new
	
	var sub = "" if new == 1.5 else "! "
	$HBoxContainer / Label.text = "Voice Pitch: " + sub + str(PlayerData.voice_pitch)

func _speed_change(new):
	PlayerData.voice_speed = new
	
	var sub = "" if new == 5 else "! "
	$HBoxContainer2 / speedlbl.text = "Voice Speed: " + sub + str(PlayerData.voice_speed)
	
	print("New speed: ", new)
