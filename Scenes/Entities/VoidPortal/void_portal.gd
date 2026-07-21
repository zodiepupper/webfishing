extends Actor

func _ready():
	$RayCast.force_raycast_update()
	$MeshInstance.global_transform.origin = $RayCast.get_collision_point() + Vector3(0.0, 0.02, 0.0)
	$MeshInstance.scale = Vector3(0.0, 0.0, 0.0)

func _physics_process(delta):
	$MeshInstance.scale = lerp($MeshInstance.scale, Vector3(1.5, 1.5, 1.5), 0.09)
