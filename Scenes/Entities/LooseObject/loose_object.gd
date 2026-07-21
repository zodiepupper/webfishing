extends Actor

var item_id = ""

func _ready():
	if item_id == "":
		queue_free()
		return
	
	var mat = $MeshInstance.get_surface_material(0).duplicate()
	mat.albedo_texture = Globals.item_data[item_id]["file"].icon
	$MeshInstance.set_surface_material(0, mat)
