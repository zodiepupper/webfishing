extends Spatial
class_name PropVis

export var cull = true
export var cull_max_range = 100
export (Vector3) var cull_size = Vector3(2.0, 2.0, 2.0)
export (Vector3) var cull_offset = Vector3(0.0, 0.0, 0.0)
export (NodePath) var premade_cull_vis

func _ready():
	if cull:
		
		var vis_node
		if premade_cull_vis:
			vis_node = get_node(premade_cull_vis)
		else:
			vis_node = VisibilityNotifier.new()
			vis_node.aabb = AABB(cull_size * - 0.5, cull_size)
			vis_node.translation = cull_offset
			add_child(vis_node)
		
		vis_node.max_distance = cull_max_range
		
		vis_node.connect("screen_entered", self, "_screen_entered")
		vis_node.connect("screen_exited", self, "_screen_exited")

func _screen_entered(): visible = true
func _screen_exited(): visible = false
