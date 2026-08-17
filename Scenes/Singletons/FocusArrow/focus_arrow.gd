extends CanvasLayer

func ready():
	get_viewport().connect("gui_focus_changed", Callable(self, "_on_focus_changed"))

func _on_focus_changed(control):
	if control != null: $TextureRect.global_position = control.global_position
