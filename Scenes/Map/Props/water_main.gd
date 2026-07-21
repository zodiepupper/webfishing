extends Spatial
class_name WaterMain

export (Material) var water_replace
onready var water = $main
onready var vis_notif = $VisibilityNotifier

func _ready():
	vis_notif.connect("screen_entered", self, "_screen_entered")
	vis_notif.connect("screen_exited", self, "_screen_exited")
	
	OptionsMenu.connect("_options_update", self, "_mat_check")
	_mat_check()

func _mat_check():
	if PlayerData.player_options.water == 0:
		water.material_override = preload("res://Assets/Materials/blue.tres")
	else:
		water.material_override = null
		if water_replace: water.material_override = water_replace

func _screen_entered(): visible = true
func _screen_exited(): visible = false
