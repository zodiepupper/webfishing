extends HBoxContainer

var collapse_node

var collapsed = true

func _on_Button_pressed():
	collapsed = not collapsed
	_refresh()

func _refresh():
	if not collapse_node: return
	collapse_node.visible = not collapsed
	$Button.text = "Expand" if collapsed else "Collapse"

func _setup(text):
	$Label.text = text
