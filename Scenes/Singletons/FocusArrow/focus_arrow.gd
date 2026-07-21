extends CanvasLayer

func ready():
	get_viewport().connect("gui_focus_changed", self, "_on_focus_changed")

func _on_focus_changed(control):
	if control != null: $TextureRect.rect_global_position = control.rect_global_position
