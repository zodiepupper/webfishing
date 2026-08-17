extends Node3D
class_name PropVis

@export var cull = true
@export var cull_max_range = 100
@export var cull_size: Vector3 = Vector3(2.0, 2.0, 2.0)
@export var cull_offset: Vector3 = Vector3(0.0, 0.0, 0.0)
@export var premade_cull_vis: NodePath

func _ready():
	if cull:
		
		var vis_node
		if premade_cull_vis:
			vis_node = get_node(premade_cull_vis)
		else:
			vis_node = VisibleOnScreenNotifier3D.new()
			vis_node.aabb = AABB(cull_size * - 0.5, cull_size)
			vis_node.position = cull_offset
			add_child(vis_node)
		
		vis_node.max_distance = cull_max_range
		
		vis_node.connect("screen_entered", Callable(self, "_screen_entered"))
		vis_node.connect("screen_exited", Callable(self, "_screen_exited"))

func _screen_entered(): visible = true
func _screen_exited(): visible = false
