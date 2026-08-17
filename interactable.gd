extends Area3D
class_name Interactable

@export var text = "INTERACT"

func _ready():
	monitoring = false
	add_to_group("interactable")

func _activate(actor):
	pass
