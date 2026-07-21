extends Spatial


var old_normal = Vector3.ZERO

onready var mesh = $MeshInstance
onready var ray = $RayCast

func _ready():
	mesh.set_as_toplevel(true)

func _process(delta):
	var dist = 40.0
	if ray.is_colliding():
		dist = abs(ray.get_collision_point().y - global_transform.origin.y)
		mesh.global_transform.origin = ray.get_collision_point() + Vector3(0.0, 0.02, 0.0)
		
		var norm = ray.get_collision_normal()
		if norm.distance_to(old_normal) > 0.04:
			if norm != Vector3.UP: mesh.look_at(mesh.global_transform.origin - norm, Vector3.UP)
			else: mesh.rotation_degrees = Vector3( - 90, 0, 0)
		
		old_normal = norm
	
	var s = max(0.0, 1.0 - (dist / 10.0))
	mesh.scale.x = s
	mesh.scale.y = s
