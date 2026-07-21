extends Node

const GAME_VERSION = 1.12
const IMAGE_FORMAT = Image.FORMAT_RGB8

var pixelize_amount = 2.25

var cosmetic_data = {}
var item_data = {}

var voice_bank = {}
var loot_tables = {}

func _ready():
	get_tree().set_auto_accept_quit(false)
	OS.set_window_title("WEBFISHING v" + str(GAME_VERSION))
	
	_load_resources()
	_generate_voice_bank()
	
	_generate_loot_tables("fish", "lake")
	_generate_loot_tables("fish", "ocean")
	_generate_loot_tables("fish", "deep")
	_generate_loot_tables("fish", "prehistoric")
	_generate_loot_tables("fish", "rain")
	_generate_loot_tables("fish", "alien")
	_generate_loot_tables("fish", "void")
	
	_generate_loot_tables("fish", "water_trash")
	
	_generate_loot_tables("bug", "bush_bug")
	_generate_loot_tables("bug", "shoreline_bug")
	_generate_loot_tables("bug", "tree_bug")
	
	_generate_loot_tables("none", "seashell")
	_generate_loot_tables("none", "trash")
	
	_generate_loot_tables("fish", "metal")

func _load_resources():
	print("Loading Resources...")
	var resource_count = 0
	var files = []
	var subdirectories = []
	var dir = Directory.new()
	var path = "res://Resources/"
	
	if dir.open(path) != OK:
		print("Error loading resource directory.")
		return
	dir.list_dir_begin(true, true)
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif dir.current_is_dir():
			subdirectories.append(file)
	
	for directory in subdirectories:
		if dir.open(path + directory) != OK:
			print("Error loading resource subdirectory ", directory)
			break
		dir.list_dir_begin(true, true)
		while true:
			var file = dir.get_next()
			if file == "":
				break
			elif file.ends_with(".tres"):
				files.append([path + directory + "/" + file, file])
				resource_count += 1
	
	for file in files:
		_add_resource(file[0], file[1])
	
	dir.list_dir_end()
	print(str(resource_count) + " Resoures Loaded from " + str(subdirectories.size()) + " Subdirectories.")

func _add_resource(file, file_name):
	file_name = file_name.replace(".tres", "")
	var read = load(file)
	if read.get("resource_type") == null:
		print("TRES file does not have resource type labeled.")
		return
	var type = read.get("resource_type")
	
	var new = {}
	new["file"] = load(file)
	match type:
		"cosmetic": cosmetic_data[file_name] = new
		"item": item_data[file_name] = new

func _generate_loot_tables(category, table):
	var new_table = {}
	new_table["entries"] = {}
	
	var total_weight = 0.0
	for item in item_data.keys():
		var data = item_data[item]["file"]
		if data.category == category and data.loot_table == table:
			total_weight += data.loot_weight
			new_table["entries"][item] = total_weight
	
	new_table["total"] = total_weight
	
	loot_tables[table] = new_table
	print("Generated Table ", table, " with category ", category)

func _roll_loot_table(table, max_tier = - 1):
	if not loot_tables.keys().has(table): return
	randomize()
	
	for i in 20:
		print("rollin")
		var roll = rand_range(0.0, loot_tables[table]["total"])
		for item in loot_tables[table]["entries"].keys():
			if loot_tables[table]["entries"][item] > roll:
				var data = Globals.item_data[item]["file"]
				if max_tier == - 1 or data.tier <= max_tier:
					print("roll ", roll, " item ", item)
					print("fish entry on roll ", roll, " is ", item, " w max tier ", max_tier)
					return item

func _get_loot_table_entries(table):
	if not loot_tables.keys().has(table): return
	return loot_tables[table]["entries"].keys()

func _roll_item_size(item):
	if not item_data.keys().has(item): return
	var base = item_data[item]["file"].average_size
	var deviation = base * 0.55
	base += base * 0.25
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var roll = stepify(rng.randfn(base, deviation), 0.01)
	roll = max(abs(roll), 0.01)
	return roll

func _enter_game(delay = 0.3):
	
	
	
	Network._wipe_chat()
	GlobalAudio._play_music("")
	SceneTransition._change_scene("res://Scenes/Menus/Loading Menu/loading_menu.tscn", delay, true, false)

func _exit_game():
	GlobalAudio._play_music("")
	SceneTransition._change_scene("res://Scenes/Menus/Main Menu/main_menu.tscn")
	yield(SceneTransition, "_finished")
	Network._leave_lobby()

func _item_exists(id): return item_data.keys().has(id)
func _cosmetic_exists(id): return cosmetic_data.keys().has(id)






func _generate_voice_bank():
	voice_bank.clear()
	
	print("Creating Voice Bank...")
	var resource_count = 0
	var files = []
	var subdirectories = []
	var dir = Directory.new()
	var path = "res://Sounds/Voice/"
	
	if dir.open(path) != OK:
		print("Error loading voice directory.")
		return
	
	dir.list_dir_begin(true, true)
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif dir.current_is_dir():
			subdirectories.append(file)
	
	for directory in subdirectories:
		voice_bank[directory] = {}
		
		if dir.open(path + directory) != OK:
			DebugScreen._add_line("Voice Subdirect error, " + str(directory))
			print("Error loading voice subdirectory ", directory)
			break
		
		dir.list_dir_begin(true, true)
		while true:
			var file = dir.get_next()
			
			if file == "":
				break
			elif file.ends_with(".ogg.import"):
				var f = File.new()
				f.open(path + directory + "/" + file, File.READ)
				
				var read = f.get_as_text()
				var final_path = ""
				
				for line in read.split("\n"):
					if line.begins_with("path="):
						var l = line.split("=")[1]
						final_path = l.replace("\"", "")
				
				var end = load(final_path)
				voice_bank[directory][file.replace(".ogg.import", "")] = end
				resource_count += 1
	
	dir.list_dir_end()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		_close_game()
		return

func _close_game(save = false):
	Network._closing_app()
	
	if save:
		UserSave._save_general_save()
		if UserSave.current_loaded_slot != - 1:
			UserSave._quick_save()
			yield(UserSave, "_slot_saved")
	
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().quit()
