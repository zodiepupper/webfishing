extends Spatial

var des_cam = 3.4
var des_height = 1.8

func _physics_process(delta):
	$item.rotation_degrees.y += 1
	$Camera.translation.x = lerp($Camera.translation.x, des_cam, 0.1)
	$Camera.translation.z = lerp($Camera.translation.z, des_cam, 0.1)
	$Camera.translation.y = lerp($Camera.translation.y, 1.6 + des_height, 0.1)
	$item / Sprite3D.translation.y = 0.555 + (sin(OS.get_ticks_msec() * 0.001) * 0.08 * $item / Sprite3D.scale.x)
