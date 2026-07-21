extends Spatial

export (NodePath) var marker_a
export (NodePath) var marker_b
export (AudioStream) var stream
export var volume = 0.0

func _ready():
	$AudioStreamPlayer3D.stream = stream
	$AudioStreamPlayer3D.unit_db = volume
	$AudioStreamPlayer3D.playing = true

func _process(delta):
	$AudioStreamPlayer3D.global_transform.origin = get_viewport().get_camera().global_transform.origin
	$AudioStreamPlayer3D.global_transform.origin.x = clamp($AudioStreamPlayer3D.global_transform.origin.x, get_node(marker_a).global_transform.origin.x, get_node(marker_b).global_transform.origin.x)
	$AudioStreamPlayer3D.global_transform.origin.y = clamp($AudioStreamPlayer3D.global_transform.origin.y, get_node(marker_a).global_transform.origin.y, get_node(marker_b).global_transform.origin.y)
	$AudioStreamPlayer3D.global_transform.origin.z = clamp($AudioStreamPlayer3D.global_transform.origin.z, get_node(marker_a).global_transform.origin.z, get_node(marker_b).global_transform.origin.z)
