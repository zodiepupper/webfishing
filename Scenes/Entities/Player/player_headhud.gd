extends MeshInstance

export var offset = Vector3()

var parent = null

func _ready():
	parent = get_parent()
	if get_tree().get_nodes_in_group("world").size() <= 0: return
	get_tree().get_nodes_in_group("world")[0]._import_child(self)

func _process(delta):
	if not is_instance_valid(parent): queue_free()
	else:
		global_transform.origin = parent.global_transform.origin + offset
		visible = parent.is_visible_in_tree()
