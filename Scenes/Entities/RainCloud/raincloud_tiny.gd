extends Actor

func _ready():
	$AudioStreamPlayer3D.unit_db = - 80.0
	$mesh.scale = Vector3(0, 0, 0)

func _physics_process(delta):
	if decay_timer > 300:
		$mesh.scale = lerp($mesh.scale, Vector3(0.3, 0.5, 0.3), 0.02)
		$AudioStreamPlayer3D.unit_db = lerp($AudioStreamPlayer3D.unit_db, 0.0, 0.01)
	else:
		$Particles.emitting = false
		$Particles_sheet.emitting = false
		$mesh.scale = lerp($mesh.scale, Vector3(0, 0, 0), 0.01)
		$AudioStreamPlayer3D.unit_db = lerp($AudioStreamPlayer3D.unit_db, - 80.0, 0.01)
	
	$mesh / MeshInstance.translation.y = sin(OS.get_ticks_msec() * 0.001) * 0.15
	$mesh / MeshInstance.translation.x = 0.2 + sin(OS.get_ticks_msec() * 0.001) * 0.15
	$mesh / MeshInstance.translation.z = - 0.2 + cos(OS.get_ticks_msec() * 0.001) * 0.15
