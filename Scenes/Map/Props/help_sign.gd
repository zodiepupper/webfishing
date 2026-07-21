extends Spatial

export (String, MULTILINE) var text = "Text here"

onready var textmesh = $textmesh

func _ready():
	$Viewport / Control / Label.text = text

func _on_Timer_timeout():
	$Viewport / Control.visible = false
	for body in $Area.get_overlapping_bodies():
		if body.is_in_group("player"):
			$Viewport / Control.visible = true
