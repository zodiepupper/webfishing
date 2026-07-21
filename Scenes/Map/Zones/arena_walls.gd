extends StaticBody

var amt = - 5
var des_scale = Vector3.ONE

func _ready():
	_reset()
	PlayerData.connect("_arena_start", self, "_reset")
	PlayerData.connect("_arena_over", self, "_reset")
	PlayerData.connect("_arena_tick", self, "_increase")

func _reset():
	amt = - 5
	des_scale = Vector3.ONE
	scale = Vector3.ONE
	$MeshInstance.visible = false

func _increase():
	amt += 1
	if amt > 0:
		var s = clamp(1.0 - (amt * 0.05), 0.25, 1.0)
		des_scale = Vector3(s, 1.0, s)
		$MeshInstance.visible = true

func _physics_process(delta):
	scale = lerp(scale, des_scale, 0.1)
