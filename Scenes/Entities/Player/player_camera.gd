extends Camera3D


func _ready():
	OptionsMenu.connect("_options_update", Callable(self, "_dist_update"))
	_dist_update()

func _dist_update():
	far = [8192, 250, 120, 25][PlayerData.player_options.view_distance]
