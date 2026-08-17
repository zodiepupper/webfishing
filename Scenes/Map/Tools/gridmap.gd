extends GridMap

const REF = {
	"floor": ["ground", "ground_1", "ground_2", "ground_3", "light_ground", "light_ground2", "light_ground3", "light_ground4"], 
	"wall": ["ground_edge"], 
	"corner": ["ground_edge_corner"], 
	"diag": ["ground_edge_corner_diag"], 
}

const FLOOR_REPLACE = {
	- 1: ["l-1_tile0"], 
	0: ["l0_tile0", "l0_tile1", "l0_tile2", "l0_tile3"], 
	1: ["l1_tile0", "l1_tile1", "l1_tile2", "l1_tile3"], 
	2: ["l2_tile0", "l2_tile1", "l2_tile2", "l2_tile3"]}

const SLOPE_REPLACE = {
	- 1: ["l-1_ground_edge"], 
	0: ["l0_ground_edge"], 
	1: ["l1_ground_edge"], 
	2: ["l2_ground_edge"], 
}

const DIAG_REPLACE = {
	- 1: ["l-1_ground_edge_corner_diag"], 
	0: ["l0_ground_edge_corner_diag"], 
	1: ["l1_ground_edge_corner_diag"], 
	2: ["l2_ground_edge_corner_diag"], 
}

const WALL_REPLACE = {
	- 1: ["l-1_ground_wall"], 
	0: ["l0_ground_wall"], 
	1: ["l1_ground_wall"], 
	2: ["l2_ground_wall"], 
}

const WALL_DIAG_REPLACE = {
	- 1: ["l-1_ground_wall_diag"], 
	0: ["l0_ground_wall_diag"], 
	1: ["l1_ground_wall__diag"], 
	2: ["l2_ground_wall_diag"], 
}

const collision = {
	"floor": "coll_ground", 
	"wall": "coll_ground_edge", 
	"corner": "", 
	"diag": "coll_ground_diag", 
}

@export var set_seed = 123123
@export var multimeshes # (Array, Texture2D)
@export var multimesh_ratio = 0.25

var mmm_bank = []

@onready var coll = $coll
@onready var invis_coll = $inviswallcoll

func _ready():
	coll.clear()
	invis_coll.clear()
	
	
	_replace_floors()
	_generate_multimeshes()

func _is_id_group(id, group):
	var string = mesh_library.get_item_name(id)
	return REF[group].has(string)

func _get_id_group(id):
	var string = mesh_library.get_item_name(id)
	for key in REF.keys():
		if REF[key].has(string):
			return key
	return ""

func _get_id_from_string(string):
	if string == "": return - 1
	return mesh_library.find_item_by_name(string)

func _generate_collisions():
	coll.clear()
	for cell in get_used_cells():
		var cell_id = get_cell_item(Vector3i(cell.x, cell.y, cell.z))
		var group = _get_id_group(cell_id)
		var is_floor = group == "floor"
		
		if group == "": continue
		
		if (is_floor and cell.y > 0) or ( not is_floor and cell.y == 0):
			var rot = get_cell_item_orientation(Vector3i(cell.x, cell.y, cell.z))
			
			if is_floor:
				print(_get_id_from_string(collision["floor"]))
				coll.set_cell_item(Vector3(cell.x, cell.y, cell.z), _get_id_from_string(collision["floor"]), rot)
			else:
				invis_coll.set_cell_item(Vector3(cell.x, cell.y, cell.z), _get_id_from_string(collision[group]), rot)
	
	print("Map Gridmap Collisions Generated")

func _replace_floors():
	seed(set_seed)
	for cell in get_used_cells():
		var cell_id = get_cell_item(Vector3i(cell.x, cell.y, cell.z))
		var iden = mesh_library.get_item_name(cell_id)
		
		var replace_bank
		var is_replacing = false
		
		match iden:
			"floor_replace":
				is_replacing = true
				replace_bank = FLOOR_REPLACE
			"slope_replace":
				is_replacing = true
				replace_bank = SLOPE_REPLACE
			"diag_replace":
				is_replacing = true
				replace_bank = DIAG_REPLACE
			"wall_replace":
				is_replacing = true
				replace_bank = WALL_REPLACE
			"wall_diag_replace":
				is_replacing = true
				replace_bank = WALL_DIAG_REPLACE
		
		if is_replacing:
			var new_id = replace_bank[int(cell.y)][0]
			if randf() < 0.25: new_id = replace_bank[int(cell.y)][randi() % replace_bank[int(cell.y)].size()]
			var rot = get_cell_item_orientation(Vector3i(cell.x, cell.y, cell.z))
			set_cell_item(Vector3(cell.x, cell.y, cell.z), _get_id_from_string(new_id), rot)

func _generate_multimeshes():
	seed(set_seed)
	var valid_floor_cells = []
	for cell in get_used_cells():
		var cell_id = get_cell_item(Vector3i(cell.x, cell.y, cell.z))
		var is_floor = _is_id_group(cell_id, "floor")
		if is_floor: valid_floor_cells.append(cell)
	
	var mm_count = floor(multimesh_ratio * valid_floor_cells.size())
	for mesh in multimeshes:
		var count = ceil(mm_count / multimeshes.size())
		var new = preload("res://Scenes/Map/Tools/multimesh.tscn").instantiate()
		add_child(new)
		new.material_override = new.material_override.duplicate(true)
		new.material_override.albedo_texture = mesh
		new.multimesh = new.multimesh.duplicate(true)
		new.multimesh.instance_count = count
		
		for id in count:
			var i = randi() % valid_floor_cells.size()
			var pos = global_transform.origin + (valid_floor_cells[i] * cell_size) + Vector3(randf_range(0.0, 2.0), 1.0, randf_range(0.0, 2.0))
			var trans = Transform3D(Basis(), pos)
			new.multimesh.set_instance_transform(id, trans)
			
