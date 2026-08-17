extends Node3D

var des_cam = 3.4
var des_height = 1.8

func _physics_process(delta):
	$item.rotation_degrees.y += 1
	$Camera3D.position.x = lerp($Camera3D.position.x, des_cam, 0.1)
	$Camera3D.position.z = lerp($Camera3D.position.z, des_cam, 0.1)
	$Camera3D.position.y = lerp($Camera3D.position.y, 1.6 + des_height, 0.1)
	$item / Sprite3D.position.y = 0.555 + (sin(Time.get_ticks_msec() * 0.001) * 0.08 * $item / Sprite3D.scale.x)
