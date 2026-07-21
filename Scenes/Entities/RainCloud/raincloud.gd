extends Actor

var wander_direction = 0
var speed = 0.17

func _setup_controlled():
	var to_center = - (global_transform.origin - Vector3(30, 40, - 50)).normalized()
	wander_direction = Vector2(to_center.x, to_center.z).angle()

func _ready():
	$AudioStreamPlayer3D.unit_db = - 80.0
	$mesh.scale = Vector3(0, 0, 0)

func _physics_process(delta):
	if decay_timer > 1000:
		$mesh.scale = lerp($mesh.scale, Vector3(6, 6, 6), 0.002)
		$AudioStreamPlayer3D.unit_db = lerp($AudioStreamPlayer3D.unit_db, 0.0, 0.01)
	else:
		$mesh.scale = lerp($mesh.scale, Vector3(0, 0, 0), 0.002)
		$AudioStreamPlayer3D.unit_db = lerp($AudioStreamPlayer3D.unit_db, - 80.0, 0.01)

func _controlled_process(delta):
	var vel = Vector2(1, 0).rotated(wander_direction) * speed
	move_and_slide(Vector3(vel.x, 0.0, vel.y))
