extends Actor


func _ready():
	Network._update_chat("[color=#1e814e]what was that...?[/color]")
	$AnimationPlayer.play("main")
	$Area.id = actor_id

func _physics_process(delta):
	if not $AnimationPlayer.is_playing():
		$meatyore.translation.y = lerp($meatyore.translation.y, (sin(OS.get_ticks_msec() * 0.001) * 0.12), 0.6)
