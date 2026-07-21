extends Spatial

const NORMAL_COLLISION_LAYER = 1;

export (NodePath) var camera

var active = false

onready var view_camera = get_node(camera)

func _raycast():
	var selected_node = null
	
	var space_state = get_world().direct_space_state
	var world_viewport = get_tree().get_nodes_in_group("world_viewport")[0]
	
	var raycast_from = view_camera.project_ray_origin(get_tree().root.get_mouse_position())
	var raycast_to = raycast_from + view_camera.project_ray_normal(world_viewport.get_mouse_position() / Globals.pixelize_amount) * 24.0
	
	var result = space_state.intersect_ray(raycast_from, raycast_to, [self])
	
	if (result.size() > 0):
		selected_node = result.collider
	









	
	return selected_node
