extends Node
class_name ItemMesh

export var item_bend = 0.0
export (NodePath) var hotspot_node

onready var hotspot = get_node(hotspot_node)
