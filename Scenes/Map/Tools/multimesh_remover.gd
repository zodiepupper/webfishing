extends Node3D

@export var radius = 5.0

func _ready():
	for mm in get_tree().get_nodes_in_group("mm"):
		var mesh = mm.multimesh
		var t = 0
		
		for i in mesh.instance_count:
			var tf = mesh.get_instance_transform(i)
			var pos = tf.origin + mm.global_transform.origin
			if pos.distance_to(global_transform.origin) < radius:
				mesh.set_instance_transform(i, Transform3D(tf.basis, pos + Vector3(0, - 100, 0)))
				t += 1
