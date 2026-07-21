extends WorldEnvironment

var des_fog = 125
var des_fog_end = 500
var des_color = Color("#ffeed5")
var des_light = 0.12

var rain = false

var default_fog = 125
var default_fog_end = 500

func _ready():
	PlayerData.connect("_rain_toggle", self, "_rain_env")
	OptionsMenu.connect("_options_update", self, "_dist_update")
	_dist_update()

func _physics_process(delta):
	var lerp_val = 0.01
	
	environment.fog_depth_begin = lerp(environment.fog_depth_begin, des_fog, lerp_val)
	environment.fog_depth_end = lerp(environment.fog_depth_end, des_fog_end, lerp_val)
	
	environment.background_color = lerp(environment.background_color, des_color, lerp_val)
	environment.ambient_light_color = lerp(environment.ambient_light_color, des_color, lerp_val)
	environment.fog_color = lerp(environment.fog_color, des_color, lerp_val)
	
	$DirectionalLight.light_energy = lerp($DirectionalLight.light_energy, des_light, lerp_val)

func _rain_env(toggle, force = false):
	if toggle == rain and not force: return
	rain = toggle
	
	if toggle:
		des_fog = 25
		des_fog_end = 75
		
		des_color = Color("#778688")
		des_light = 0.06
	
	else:
		des_fog = default_fog
		des_fog_end = default_fog_end
		des_color = Color("#ffeed5")
		des_light = 0.12

func _dist_update():
	default_fog = [125, 50, 15, 6][PlayerData.player_options.view_distance]
	default_fog_end = [500, 200, 75, 12][PlayerData.player_options.view_distance]
	_rain_env(rain, true)
