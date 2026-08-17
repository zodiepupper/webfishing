extends Node3D

@export var text = "Text here" # (String, MULTILINE)

@onready var textmesh = $textmesh

func _ready():
	$SubViewport / Control / Label.text = text

func _on_Timer_timeout():
	$SubViewport / Control.visible = false
	for body in $Area3D.get_overlapping_bodies():
		if body.is_in_group("player"):
			$SubViewport / Control.visible = true
