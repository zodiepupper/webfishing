extends Node3D

enum BrushMode{
	PENCIL, 
	ERASER, 
}

@export var canvas_size = 9.0
@export var canvas_id = 0
@export var inherit_id: NodePath
@export var circular = true

var last_mouse_pos = Vector2()
var mouse_click_start_pos = Vector2.INF

var brush_mode = BrushMode.PENCIL
var brush_size = 1
var step_size = 1
var brush_color = 0

var brush_off_canvas = false
var canvas_boundry = 0
var canvas_mid = 0

var send_load = []

@onready var vis_node = $VisibleOnScreenNotifier3D

func _ready():
	$SubViewport / TileMap.clear()
	$GridMap.clear()
	
	if inherit_id:
		canvas_id = get_node(inherit_id).actor_id
		rotation = Vector3.ZERO
	
	canvas_boundry = canvas_size * 10
	canvas_mid = 0
	$Area3D.scale = Vector3.ONE * canvas_size
	
	var vis_size = canvas_size * 1.5
	var vec = Vector3(vis_size, vis_size, vis_size)
	vis_node.aabb = AABB(vec * - 0.5, vec)
	vis_node.connect("screen_entered", Callable(self, "_screen_entered"))
	vis_node.connect("screen_exited", Callable(self, "_screen_exited"))
	
	PlayerData.connect("_chalk_draw", Callable(self, "_chalk_draw"))
	PlayerData.connect("_chalk_update", Callable(self, "_chalk_update"))
	PlayerData.connect("_chalk_send", Callable(self, "_chalk_send"))
	PlayerData.connect("_chalk_recieve", Callable(self, "_chalk_recieve"))
	
	OptionsMenu.connect("_options_update", Callable(self, "_options_update"))
	
	Network.connect("_new_player_join", Callable(self, "_chalk_send_total"))

func _chalk_update(pos):
	last_mouse_pos = pos

func _chalk_draw(pos, size, color):
	brush_color = color
	brush_size = size
	step_size = size
	
	var diff = (global_transform.origin - pos)
	if diff.length() > canvas_size and circular:
		last_mouse_pos = global_transform.origin + (diff.normalized() * - canvas_size)
		return
	
	var p = $GridMap.local_to_map(pos - global_transform.origin)
	p = Vector2(p.x, p.z)
	
	var p2 = $GridMap.local_to_map(last_mouse_pos - global_transform.origin)
	p2 = Vector2(p2.x, p2.z)
	
	_add_brush(p, brush_mode, p2)
	last_mouse_pos = pos

func _add_brush(grid_pos, type, from):
	var color = brush_color
	if type == BrushMode.ERASER: color = - 1
	
	var steps = 1 + floor(from.distance_to(grid_pos) / step_size)
	for s in steps:
		var step = (s * step_size) * (from - grid_pos).normalized()
		
		var pos = grid_pos + step
		
		for x in brush_size:
			for y in brush_size:
				var final = _clamp_cell(pos + Vector2(x, y))
				
				$SubViewport / TileMap.set_cell(final.x, final.y, color)
				send_load.append([final, color])

func _chalk_send():
	if send_load.size() > 0:
		Network._send_P2P_Packet({"type": "chalk_packet", "data": send_load.duplicate(), "canvas_id": canvas_id}, "all", 2, Network.CHANNELS.CHALK)
	send_load.clear()

func _chalk_send_total(id):
	if not Network.GAME_MASTER: return
	var total_load = []
	for cell in $SubViewport / TileMap.get_used_cells():
		var color = int($SubViewport / TileMap.get_cell(cell.x, cell.y))
		total_load.append([Vector2(cell.x, cell.y), color])
	
	if total_load.size() > 0:
		Network._send_P2P_Packet({"type": "chalk_packet", "data": total_load.duplicate(), "canvas_id": canvas_id}, str(id), 2, Network.CHANNELS.CHALK)

func _chalk_recieve(data, id):
	if id != canvas_id: return
	for d in data:
		var pos = _clamp_cell(d[0], 0)
		var color = d[1]
		if not (color is int): color = 0
		$SubViewport / TileMap.set_cell(pos.x, pos.y, color)

func _clamp_cell(pos, offset = 100):
	var grid_offset = 100
	var final = Vector2(pos.x + offset, pos.y + offset)
	final.x = clamp(final.x, - grid_offset, grid_offset * 2)
	final.y = clamp(final.y, - grid_offset, grid_offset * 2)
	return final

func _screen_entered():
	visible = true
	$SubViewport / TileMap.visible = not OptionsMenu.chalk_disabled
func _screen_exited():
	visible = false
	$SubViewport / TileMap.visible = false

func _options_update():
	$SubViewport / TileMap.visible = not OptionsMenu.chalk_disabled
