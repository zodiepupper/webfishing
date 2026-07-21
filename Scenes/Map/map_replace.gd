tool
extends EditorScript

func _run():
	var scene = get_scene()
	var gridmap = scene.get_child(0)
	
	var old_tiles = gridmap.get_used_cells()
	for cell in old_tiles:
		var item = gridmap.get_cell_item(cell.x, cell.y, cell.z)
		if item == 3:
			gridmap.set_cell_item(cell.x, cell.y, cell.z, 1)
