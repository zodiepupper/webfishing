extends Node



const GENERAL_PATH = "user://webfishing_general_data.sav"

const OLD_MIGRATED_PATH = "user://webfishing_migrated_data.save"
const OLD_ORIGINAL_PATH = "user://webfishing_data.save"


var stored_general_save: Dictionary = {}
var player_options: Dictionary = {}
var last_loaded_slot: int = - 1
var current_loaded_slot: int = - 1
var prompt_save_selection = false

var saving_in_progress = false
var general_saving_in_progress = false
var general_save_loaded = false

signal _slot_saved


func _ready():
	
	yield(get_tree().create_timer(2.0), "timeout")
	
	var save_exists = _load_general_save()
	if not save_exists: _reset_general_save()
	else: general_save_loaded = true
	
	_migration_check()






func _migration_check():
	print("Checking for save migrations...")
	var SAVE_PATH = "user://webfishing_save_slot_0.sav"
	var BACKUP_PATH = "user://webfishing_backup_save_slot_0.backup"
	
	var save = File.new()
	var save_exists = save.file_exists(SAVE_PATH)
	var backup_exists = save.file_exists(BACKUP_PATH)
	var migrate_exists = save.file_exists(OLD_MIGRATED_PATH)
	var orignal_exists = save.file_exists(OLD_ORIGINAL_PATH)
	
	if save_exists or backup_exists:
		print("Migrated save found.")
		return
	
	print("Preparing to migrate data...")
	_port_data_to_save(0, not migrate_exists)







func _load_general_save():
	var save = File.new()
	if not save.file_exists(GENERAL_PATH):
		print("No General Save found.")
		return false
	print("Loading General Save")
	
	save.open(GENERAL_PATH, File.READ)
	stored_general_save = save.get_var()
	save.close()
	
	stored_general_save = _version_key_check(stored_general_save, true)
	
	
	player_options = stored_general_save.player_options
	last_loaded_slot = stored_general_save.last_loaded_slot
	
	PlayerData.player_options = player_options
	OptionsMenu._update_options()
	
	
	if last_loaded_slot != - 1:
		_load_save(last_loaded_slot)
	else:
		prompt_save_selection = true
	
	return true

func _save_general_save():
	if general_saving_in_progress or not general_save_loaded:
		print("Saving general save failed, already saving.")
		return
	general_saving_in_progress = true
	
	var new_save = {
		"player_options": player_options, 
		"last_loaded_slot": last_loaded_slot, 
	}
	
	print("Saving General Game")
	var save = File.new()
	save.open("user://webfishing_general_data.sav", File.WRITE)
	save.store_var(new_save)
	save.close()
	
	yield(get_tree().create_timer(0.25), "timeout")
	general_saving_in_progress = false

func _reset_general_save():
	print("Resetting General Save")
	last_loaded_slot = - 1
	player_options = {
		"res": Vector2(1600, 900), 
		"fullscreen": 0, 
		"vsync": 1, 
		"fps_limit": 0, 
		"water": 1, 
		"view_distance": 0, 
		"pixel": 1, 
		"main_vol": 0.7, 
		"sfx_vol": 1.0, 
		"music_vol": 1.0, 
		"mouse_sens": 0.05, 
		"mouse_invert": 0, 
		"key_rebindings": [], 
		"resizeable": 0, 
		"punchable": 0, 
		"sprint_toggle": 0, 
		"disable_chalk": 0, 
		"catch_bell": 0, 
		"chat_filter": 0, 
		"mail_close": 0, 
		"autoclick": 0, 
		"altfont": 0, 
	}
	
	general_save_loaded = true
	PlayerData.player_options = player_options
	OptionsMenu._update_options()
	call_deferred("_save_general_save")







func _load_save(slot):
	print("Loading Save Slot ", slot)
	var SAVE_PATH = "user://webfishing_save_slot_" + str(slot) + ".sav"
	var BACKUP_PATH = "user://webfishing_backup_save_slot_" + str(slot) + ".backup"
	
	last_loaded_slot = slot
	current_loaded_slot = slot
	
	var save = File.new()
	
	
	var save_exists = save.file_exists(SAVE_PATH)
	var backup_exists = save.file_exists(BACKUP_PATH)
	
	
	var use_backup = false
	if not save_exists:
		
		if backup_exists:
			print("Defaulting to save backup.")
			use_backup = true
		
		
		else:
			_reset_save_slot(slot)
			return
	
	var loaded_save = {}
	if not use_backup: save.open(SAVE_PATH, File.READ)
	else: save.open(BACKUP_PATH, File.READ)
	loaded_save = save.get_var()
	save.close()
	
	
	var reset = false
	if loaded_save == null:
		print("Save broken.")
		if not use_backup:
			print("Attempting Backup.")
			save.open(BACKUP_PATH, File.READ)
			loaded_save = save.get_var()
			save.close()
			
			if loaded_save == null: reset = true
		else:
			reset = true
	
	if reset:
		print("Resetting.")
		_reset_save_slot(slot)
		return
	
	
	loaded_save = _version_key_check(loaded_save, false)
	
	
	PlayerData.inventory = loaded_save.inventory
	PlayerData.hotbar = loaded_save.hotbar
	PlayerData.cosmetics_unlocked = loaded_save.cosmetics_unlocked
	PlayerData.cosmetics_equipped = loaded_save.cosmetics_equipped
	PlayerData.money = loaded_save.money
	
	PlayerData.players_muted = loaded_save.muted_players
	PlayerData.players_hidden = loaded_save.hidden_players
	
	PlayerData.bait_inv = loaded_save.bait_inv
	PlayerData.bait_selected = loaded_save.bait_selected
	PlayerData.bait_unlocked = loaded_save.bait_unlocked
	PlayerData.max_bait = loaded_save.max_bait
	
	PlayerData.lure_unlocked = loaded_save.lure_unlocked
	PlayerData.lure_selected = loaded_save.lure_selected
	
	PlayerData.journal_logs = loaded_save.journal
	PlayerData.current_quests = loaded_save.quests
	PlayerData.completed_quests = loaded_save.completed_quests
	PlayerData.badge_level = loaded_save.level
	PlayerData.badge_xp = loaded_save.xp
	PlayerData.saved_aqua_fish = loaded_save.saved_aqua_fish
	PlayerData.inbound_mail = loaded_save.inbound_mail
	PlayerData.saved_tags = loaded_save.saved_tags
	PlayerData.loan_level = loaded_save.loan_level
	PlayerData.loan_left = loaded_save.loan_left
	
	PlayerData.rod_power_level = loaded_save.rod_power
	PlayerData.rod_speed_level = loaded_save.rod_speed
	PlayerData.rod_chance_level = loaded_save.rod_chance
	PlayerData.rod_luck_level = loaded_save.rod_luck
	PlayerData.buddy_level = loaded_save.buddy_level
	PlayerData.buddy_speed = loaded_save.buddy_speed
	
	PlayerData.guitar_shapes = loaded_save.guitar_shapes
	PlayerData.fish_caught = loaded_save.fish_caught
	PlayerData.cash_total = loaded_save.cash_total
	PlayerData.voice_pitch = loaded_save.voice_pitch
	PlayerData.voice_speed = loaded_save.voice_speed
	PlayerData.locked_refs = loaded_save.locked_refs
	
	PlayerData._validate_guitar_shapes()
	PlayerData._validate_inventory()
	PlayerData._journal_check()
	PlayerData._missing_quest_check()
	PlayerData._unlock_defaults()

func _version_key_check(data, general = false):
	if general:
		
		if not data["player_options"].keys().has("resizeable"): data["player_options"]["resizeable"] = 0
		if not data["player_options"].keys().has("punchable"): data["player_options"]["punchable"] = 0
		if not data["player_options"].keys().has("sprint_toggle"): data["player_options"]["sprint_toggle"] = 0
		if not data["player_options"].keys().has("disable_chalk"): data["player_options"]["disable_chalk"] = 0
		if not data["player_options"].keys().has("catch_bell"): data["player_options"]["catch_bell"] = 0
		if not data["player_options"].keys().has("chat_filter"): data["player_options"]["chat_filter"] = 0
		if not data["player_options"].keys().has("mail_close"): data["player_options"]["mail_close"] = 0
		if not data["player_options"].keys().has("autoclick"): data["player_options"]["autoclick"] = 0
		if not data["player_options"].keys().has("altfont"): data["player_options"]["altfont"] = 0
		if not data["player_options"].keys().has("instrument_vol"): data["player_options"]["instrument_vol"] = 1.0
	
	else:
		if not data.keys().has("rod_luck"): data["rod_luck"] = 0
		if not data.keys().has("guitar_shapes"): data["guitar_shapes"] = PlayerData.DEFAULT_GUITAR_SHAPES.duplicate(true)
		if not data.keys().has("fish_caught"): data["fish_caught"] = 0
		if not data.keys().has("cash_total"): data["cash_total"] = 25
		if not data.keys().has("voice_speed"): data["voice_speed"] = 5
		if not data.keys().has("voice_pitch"): data["voice_pitch"] = 1.5
		if not data.keys().has("locked_refs"): data["locked_refs"] = []
		if not data.keys().has("completed_quests"): data["completed_quests"] = []
	
	return data

func _save_slot(slot):
	if saving_in_progress:
		print("Saving Slot ", slot, " failed, already saving.")
		return
	saving_in_progress = true
	
	print("Saving Save Slot ", slot)
	var SAVE_PATH = "user://webfishing_save_slot_" + str(slot) + ".sav"
	var BACKUP_PATH = "user://webfishing_backup_save_slot_" + str(slot) + ".backup"
	
	var new_save = {
		"inventory": PlayerData.inventory, 
		"hotbar": PlayerData.hotbar, 
		"cosmetics_unlocked": PlayerData.cosmetics_unlocked, 
		"cosmetics_equipped": PlayerData.cosmetics_equipped, 
		"new_cosmetics": [], 
		"version": Globals.GAME_VERSION, 
		"muted_players": PlayerData.players_muted, 
		"hidden_players": PlayerData.players_hidden, 
		"recorded_time": PlayerData.last_recorded_time, 
		"money": PlayerData.money, 
		"bait_inv": PlayerData.bait_inv, 
		"bait_selected": PlayerData.bait_selected, 
		"bait_unlocked": PlayerData.bait_unlocked, 
		"shop": PlayerData.current_shop, 
		"journal": PlayerData.journal_logs, 
		"quests": PlayerData.current_quests, 
		"completed_quests": PlayerData.completed_quests, 
		"level": PlayerData.badge_level, 
		"xp": PlayerData.badge_xp, 
		"max_bait": PlayerData.max_bait, 
		"lure_unlocked": PlayerData.lure_unlocked, 
		"lure_selected": PlayerData.lure_selected, 
		"saved_aqua_fish": PlayerData.saved_aqua_fish, 
		"inbound_mail": PlayerData.inbound_mail, 
		"rod_power": PlayerData.rod_power_level, 
		"rod_speed": PlayerData.rod_speed_level, 
		"rod_chance": PlayerData.rod_chance_level, 
		"rod_luck": PlayerData.rod_luck_level, 
		"saved_tags": PlayerData.saved_tags, 
		"loan_level": PlayerData.loan_level, 
		"loan_left": PlayerData.loan_left, 
		"buddy_level": PlayerData.buddy_level, 
		"buddy_speed": PlayerData.buddy_speed, 
		"guitar_shapes": PlayerData.guitar_shapes, 
		"fish_caught": PlayerData.fish_caught, 
		"cash_total": PlayerData.cash_total, 
		"voice_pitch": PlayerData.voice_pitch, 
		"voice_speed": PlayerData.voice_speed, 
		"locked_refs": PlayerData.locked_refs, 
	}
	
	var save = File.new()
	save.open(SAVE_PATH, File.WRITE)
	save.store_var(new_save)
	save.close()
	
	
	save = File.new()
	save.open(BACKUP_PATH, File.WRITE)
	save.store_var(new_save)
	save.close()
	
	yield(get_tree().create_timer(0.25), "timeout")
	saving_in_progress = false
	call_deferred("emit_signal", "_slot_saved")


func _reset_save_slot(slot):
	print("Save Slot ", slot, " Reset")
	last_loaded_slot = slot
	current_loaded_slot = slot
	PlayerData.connect("_save_reset", self, "_save_slot", [slot], CONNECT_ONESHOT)
	PlayerData._reset_save()


func _port_data_to_save(slot, original = false):
	print("Porting Save Data to Slot ", slot, " OG: ", original)
	var SAVE_PATH = "user://webfishing_save_slot_" + str(slot) + ".sav"
	var save_data = {}
	
	var save = File.new()
	if not original: save.open("user://webfishing_migrated_data.save", File.READ)
	else: save.open_encrypted_with_pass("user://webfishing_data.save", File.READ, "97C4B57AF4E0F527")
	save_data = save.get_var()
	save.close()
	
	var save_slot_new = File.new()
	save_slot_new.open(SAVE_PATH, File.WRITE)
	save_slot_new.store_var(save_data)
	save_slot_new.close()


func _quick_save():
	if current_loaded_slot == - 1: return
	
	print("Attempting to save the game...")
	_save_slot(current_loaded_slot)
	
	
	var save_anim = preload("res://Scenes/Singletons/UserSave/save_animation.tscn").instance()
	add_child(save_anim)

func _quick_open(slot):
	var SAVE_PATH = "user://webfishing_save_slot_" + str(slot) + ".sav"
	var save = File.new()
	if not save.file_exists(SAVE_PATH): return {}
	
	save.open(SAVE_PATH, File.READ)
	var data = save.get_var()
	save.close()
	
	if data == null: data = {}
	
	return data
