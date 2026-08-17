extends MeshInstance3D

func _ready():
	seed(12341234)
	rotation_degrees.y = global_rotation.x + global_rotation.z * randf_range(0.0, 500.0)
	
