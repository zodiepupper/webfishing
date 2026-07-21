extends MeshInstance

func _ready():
	seed(12341234)
	rotation_degrees.y = global_rotation.x + global_rotation.z * rand_range(0.0, 500.0)
	
