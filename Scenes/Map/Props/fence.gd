extends Node3D

@export var show_cap = false

func _ready():
	$Icosphere2.visible = show_cap
