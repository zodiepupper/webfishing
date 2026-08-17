extends Actor

func _ready():
	$RayCast3D.force_raycast_update()
	$MeshInstance3D.global_transform.origin = $RayCast3D.get_collision_point() + Vector3(0.0, 0.02, 0.0)
	$MeshInstance3D.scale = Vector3(0.0, 0.0, 0.0)

func _physics_process(delta):
	$MeshInstance3D.scale = lerp($MeshInstance3D.scale, Vector3(1.5, 1.5, 1.5), 0.09)
