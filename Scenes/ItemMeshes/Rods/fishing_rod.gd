extends ItemMesh

onready var anim_tree = $AnimationTree

func _ready():
	anim_tree.tree_root = anim_tree.tree_root.duplicate(true)

func _physics_process(delta):
	anim_tree.set("parameters/pole_bend/blend_amount", item_bend)
