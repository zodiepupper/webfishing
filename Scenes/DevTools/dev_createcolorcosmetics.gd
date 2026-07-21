extends Control

var selected_dir = ""
var selected_file = ""

func _on_FileDialog_dir_selected(dir):
	selected_dir = dir
	$Label.text = str(selected_dir)

func _on_FileDialog_file_selected(path):
	selected_file = path
	$Label2.text = str(selected_file)

func _on_Button_pressed():
	$FileDialog.mode = FileDialog.MODE_OPEN_DIR
	$FileDialog.show()

func _on_Button2_pressed():
	$FileDialog.mode = FileDialog.MODE_OPEN_FILE
	$FileDialog.show()


func _on_Button3_pressed():
	var colors = {
		"White": "#ffeed5", 
		"Tan": "#d5aa73", 
		"Brown": "#6a4420", 
		"Red": "#ff0031", 
		"Maroon": "#ac0029", 
		"Grey": "#a4756a", 
		"Green": "#525900", 
		"Blue": "#008583", 
		"Purple": "#4a2c4a", 
		"Salmon": "#f6856a", 
		"Yellow": "#e69d00", 
		"Black": "#101c31", 
		"Orange": "#c54400", 
		"Olive": "#a4aa39", 
		"Teal": "#5a755a", 
	}
	
	var mats = {
		"White": preload("res://Assets/Materials/white.tres"), 
		"Tan": preload("res://Assets/Materials/tan.tres"), 
		"Brown": preload("res://Assets/Materials/brown.tres"), 
		"Red": preload("res://Assets/Materials/red.tres"), 
		"Maroon": preload("res://Assets/Materials/maroon.tres"), 
		"Grey": preload("res://Assets/Materials/gray_b.tres"), 
		"Green": preload("res://Assets/Materials/dark_green_b.tres"), 
		"Blue": preload("res://Assets/Materials/blue.tres"), 
		"Purple": preload("res://Assets/Materials/purple.tres"), 
		"Salmon": preload("res://Assets/Materials/pink.tres"), 
		"Yellow": preload("res://Assets/Materials/yellow.tres"), 
		"Black": preload("res://Assets/Materials/dark.tres"), 
		"Orange": preload("res://Assets/Materials/orange.tres"), 
		"Olive": preload("res://Assets/Materials/green_c.tres"), 
		"Teal": preload("res://Assets/Materials/teal.tres"), 
	}
	
	
	var template = load(selected_file).duplicate()
	
	for color in colors.keys():
		var new = template.duplicate()
		var file_name = $LineEdit.text + "_" + str(color).to_lower() + ".tres"
		new.main_color = Color(colors[color])
		new.name = str(color) + " " + template.name
		
		if $CheckBox.pressed:
			new.material = mats[color]
		
		var result = ResourceSaver.save(selected_dir + "/" + file_name, new)
		print(result)
