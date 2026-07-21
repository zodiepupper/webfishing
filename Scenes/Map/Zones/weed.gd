extends MeshInstance

var offset = 0

func _ready():
	randomize()
	offset = randi() % 1000

func _physics_process(delta):
	var t = OS.get_ticks_msec() + offset
	rotation_degrees.x = sin(t * 0.002) * 3
	rotation_degrees.z = sin(t * 0.002) * 3
