extends AnimationPlayer

var avoid_list = ["rod_wind"]

func _ready():
	for anim in get_animation_list():
		if not avoid_list.has(anim):
			var a = get_animation(anim)
			a.set_loop(true)
