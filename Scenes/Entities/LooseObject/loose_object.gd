extends Actor

var item_id = ""

func _ready():
	if item_id == "":
		queue_free()
		return
	
	var mat = $MeshInstance3D.get_surface_override_material(0).duplicate()
	mat.albedo_texture = Globals.item_data[item_id]["file"].icon
	$MeshInstance3D.set_surface_override_material(0, mat)
