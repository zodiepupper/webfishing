extends Node

export (NodePath) var gm
export var active = true

func _run():
	if not active: return
	seed(123123123)
	
	var gridmap = get_node(gm)
	if not is_instance_valid(gridmap):
		print("Gridmap Script Error: No Gridmap Found")
		return
	
	var cells = gridmap.get_used_cells().duplicate()
	
	
	for tile in cells:
		var cell_id = gridmap.get_cell_item(tile.x, tile.y, tile.z)
		var empty_sides = []
		var empty_side_orientations = []
		
		if not (cell_id == 7 or cell_id == 11): continue
		
		var dirs = [Vector3(1, 0, 0), Vector3(0, 0, - 1), Vector3( - 1, 0, 0), Vector3(0, 0, 1)]
		var orienations = [0, 16, 10, 22]
		
		for dir in dirs.size():
			var pos = tile + dirs[dir]
			if not cells.has(pos):
				empty_sides.append(pos)
				empty_side_orientations.append(orienations[dir])
		
		for i in empty_sides.size():
			var side = empty_sides[i]
			var ori = empty_side_orientations[i]
			var side_id = gridmap.get_cell_item(side.x, side.y, side.z)
			if side_id == 3:
				
				gridmap.set_cell_item(side.x, side.y, side.z, 5, ori)
			else:
				gridmap.set_cell_item(side.x, side.y, side.z, 3, ori)
	
	
	var tree_chance = 0.02
	for tile in cells:
		if randf() < tree_chance:
			var cell_id = gridmap.get_cell_item(tile.x, tile.y, tile.z)
			if not (cell_id == 7 or cell_id == 11): continue
			if cells.has(tile + Vector3(0, 1, 0)): continue
			
			var tree = load("res://Scenes/Map/Props/tree_" + str(randi() % 3 + 1) + ".tscn").instance()
			tree.global_transform.origin = gridmap.map_to_world(tile.x, tile.y, tile.z)
			gridmap.add_child(tree)
	
	gridmap._replace_floors()

func _ready():
	_run()
