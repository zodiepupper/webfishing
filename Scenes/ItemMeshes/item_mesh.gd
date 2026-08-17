extends Node
class_name ItemMesh

@export var item_bend = 0.0
@export var hotspot_node: NodePath

@onready var hotspot = get_node(hotspot_node)
