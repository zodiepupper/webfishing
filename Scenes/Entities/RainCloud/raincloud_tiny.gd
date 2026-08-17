extends Actor

func _ready():
	$AudioStreamPlayer3D.volume_db = - 80.0
	$mesh.scale = Vector3(0, 0, 0)

func _physics_process(delta):
	if decay_timer > 300:
		$mesh.scale = lerp($mesh.scale, Vector3(0.3, 0.5, 0.3), 0.02)
		$AudioStreamPlayer3D.volume_db = lerp($AudioStreamPlayer3D.volume_db, 0.0, 0.01)
	else:
		$Particles.emitting = false
		$Particles_sheet.emitting = false
		$mesh.scale = lerp($mesh.scale, Vector3(0, 0, 0), 0.01)
		$AudioStreamPlayer3D.volume_db = lerp($AudioStreamPlayer3D.volume_db, - 80.0, 0.01)
	
	$mesh / MeshInstance3D.position.y = sin(Time.get_ticks_msec() * 0.001) * 0.15
	$mesh / MeshInstance3D.position.x = 0.2 + sin(Time.get_ticks_msec() * 0.001) * 0.15
	$mesh / MeshInstance3D.position.z = - 0.2 + cos(Time.get_ticks_msec() * 0.001) * 0.15
