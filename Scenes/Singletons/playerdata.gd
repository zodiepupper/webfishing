extends Node

enum ITEM_QUALITIES{NORMAL, SHINING, GLISTENING, OPULENT, RADIANT, ALPHA}
const QUALITY_DATA = {
	ITEM_QUALITIES.NORMAL: {"color": "#d5aa73", "name": "", "diff": 1.0, "bdiff": 0.0, "worth": 1.0, "mod": "#ffffff", "op": 1.0, "particle": - 1, "title": "Normal "}, 
	ITEM_QUALITIES.SHINING: {"color": "#d5aa73", "name": "Shining ", "diff": 1.5, "bdiff": 3.0, "worth": 1.8, "mod": "#e5f5f0", "op": 1.0, "particle": 0, "title": "Shining "}, 
	ITEM_QUALITIES.GLISTENING: {"color": "#a49d9c", "name": "Glistening ", "diff": 2.5, "bdiff": 8.0, "worth": 4.0, "mod": "#eafcf5", "op": 1.0, "particle": 1, "title": "Glistening "}, 
	ITEM_QUALITIES.OPULENT: {"color": "#008583", "name": "Opulent ", "diff": 4.0, "bdiff": 14.0, "worth": 6.0, "mod": "#d5fcf5", "op": 1.0, "particle": 2, "title": "Opulent "}, 
	ITEM_QUALITIES.RADIANT: {"color": "#e69d00", "name": "Radiant ", "diff": 5.0, "bdiff": 24.0, "worth": 10.0, "mod": "#fcf0d5", "op": 1.0, "particle": 3, "title": "Radiant "}, 
	ITEM_QUALITIES.ALPHA: {"color": "#cd0462", "name": "Alpha ", "diff": 5.5, "bdiff": 32.0, "worth": 15.0, "mod": "#fcd5df", "op": 1.0, "particle": 4, "title": "Alpha "}, 
}
const BAIT_DATA = {
	"": {"icon": preload("res://Assets/Textures/UI/bait_icons1.png"), "name": "No Bait", "desc": "No chance of catching anything with this!", "cost": 0}, 
	"worms": {"icon": preload("res://Assets/Textures/UI/bait_icons2.png"), "name": "Worms", "desc": "Low Quality Cheap Bait\nCatches Low Tier fish only", "cost": 0}, 
	"cricket": {"icon": preload("res://Assets/Textures/UI/bait_icons3.png"), "name": "Crickets", "desc": "Standard Quality Cheap Bait\nCatches all Tiers of fish\nLow chance of finding SHINING fish", "cost": 20}, 
	"leech": {"icon": preload("res://Assets/Textures/UI/bait_icons4.png"), "name": "Leeches", "desc": "Above Standard Quality Bait\nCatches all Tiers of fish\nLow chance of finding GLISTENING fish", "cost": 50}, 
	"minnow": {"icon": preload("res://Assets/Textures/UI/bait_icons5.png"), "name": "Minnows", "desc": "High Quality Bait\nCatches all Tiers of fish\nLow chance of finding OPULENT fish", "cost": 100}, 
	"squid": {"icon": preload("res://Assets/Textures/UI/bait_icons6.png"), "name": "Squid", "desc": "Very High Quality Bait\nCatches all Tiers of fish\nLow chance of finding RADIANT fish", "cost": 200}, 
	"nautilus": {"icon": preload("res://Assets/Textures/UI/bait_icons7.png"), "name": "Nautiluses", "desc": "Pristine Quality Bait\nCatches all Tiers of fish\nLow chance of finding ALPHA fish", "cost": 500}, 
	"gildedworm": {"icon": preload("res://Assets/Textures/UI/bait_icons25.png"), "name": "Gilded Worm", "desc": "Pristine Quality Bait\nCatches all Tiers of fish\nBest chance of finding ALPHA fish", "cost": 1200}, 
}

const LURE_DATA = {
	"": {"icon": preload("res://Assets/Textures/UI/bait_icons9.png"), "name": "Bare Hook", "desc": "Simple fishhook with no special qualities", "effect_id": ""}, 
	"fly_hook": {"icon": preload("res://Assets/Textures/UI/bait_icons10.png"), "name": "Fly Hook", "desc": "Catches have a higher chance of being smaller fish", "effect_id": "small"}, 
	"lucky_hook": {"icon": preload("res://Assets/Textures/UI/bait_icons11.png"), "name": "Lucky Hook", "desc": "Gain a small amount of cash on every catch", "effect_id": "lucky"}, 
	"patient_lure": {"icon": preload("res://Assets/Textures/UI/bait_icons12.png"), "name": "Patient Lure", "desc": "Catches wait for your input before beginning to reel in", "effect_id": "patient"}, 
	"quick_jig": {"icon": preload("res://Assets/Textures/UI/bait_icons13.png"), "name": "Quick Jig", "desc": "Reel Quicker and gain Rod Power", "effect_id": "quick"}, 
	"salty_lure": {"icon": preload("res://Assets/Textures/UI/bait_icons19.png"), "name": "Salty Lure", "desc": "Always catch Saltwater fish, no matter the body of water.", "effect_id": "salty"}, 
	"fresh_lure": {"icon": preload("res://Assets/Textures/UI/bait_icons21.png"), "name": "Fresh Lure", "desc": "Always catch Freshwater fish, no matter the body of water.", "effect_id": "fresh"}, 
	"efficient_lure": {"icon": preload("res://Assets/Textures/UI/bait_icons14.png"), "name": "Efficient Lure", "desc": "Chance to not consume bait on catch", "effect_id": "efficient"}, 
	"magnet_lure": {"icon": preload("res://Assets/Textures/UI/bait_icons15.png"), "name": "Magnet Lure", "desc": "Higher chance of catching treasure (and garbage...)", "effect_id": "magnet"}, 
	"large_lure": {"icon": preload("res://Assets/Textures/UI/bait_icons16.png"), "name": "Large Lure", "desc": "Higher chance of catching bigger fish\n... chance to consume extra bait on catch", "effect_id": "large"}, 
	"attractive_angler": {"icon": preload("res://Assets/Textures/UI/bait_icons17.png"), "name": "Attractive Angler", "desc": "Higher catch chance", "effect_id": "attractive"}, 
	"sparkling_lure": {"icon": preload("res://Assets/Textures/UI/bait_icons18.png"), "name": "Sparkling Lure", "desc": "Higher chance of catching greater tiers of fish\n... chance to consume extra bait on catch", "effect_id": "sparkling"}, 
	"double_hook": {"icon": preload("res://Assets/Textures/UI/bait_icons20.png"), "name": "Double Hook", "desc": "Low Chance of doubling fish on catch\n... chance to consume extra bait on catch", "effect_id": "double"}, 
	"gold_hook": {"icon": preload("res://Assets/Textures/UI/bait_icons22.png"), "name": "Golden Hook", "desc": "Higher chance of catching extremely rare fish\n... always consumes 3x bait.", "effect_id": "gold"}, 
	"challenge_lure": {"icon": preload("res://Assets/Textures/UI/bait_icons23.png"), "name": "Challenge Lure", "desc": "Popups appear during the fishing minigame, clicking them gives cash- but missing them hurts you!", "effect_id": "challenge"}, 
	"rain_lure": {"icon": preload("res://Assets/Textures/UI/bait_icons24.png"), "name": "Shower Lure", "desc": "On catch, small chance to summon a tiny rainstorm above you.", "effect_id": "rain"}, 
}

const LOAN_DATA = {
	0: 250, 
	1: 2500, 
	2: 10000, 
	3: 10000, 
}

const REFRESH_TIME = 30
const QUEST_REFRESH_TIME = 60
const SELL_REFRESH_TIME = 60

const BADGE_LEVEL_DATA = {
	1: {"title": "SCOUT", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges1.png"), "reward": [], "quest": []}, 
	2: {"title": "SCOUT II", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges1.png"), "reward": [], "quest": []}, 
	3: {"title": "SCOUT III", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges1.png"), "reward": [], "quest": []}, 
	4: {"title": "SCOUT IV", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges1.png"), "reward": [], "quest": []}, 
	5: {"title": "TENDERFOOT", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges2.png"), "reward": ["title_rank_5"], "quest": ["", "ocean", 5, 100, 250]}, 
	6: {"title": "TENDERFOOT II", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges2.png"), "reward": [], "quest": []}, 
	7: {"title": "TENDERFOOT III", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges2.png"), "reward": [], "quest": []}, 
	8: {"title": "TENDERFOOT IV", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges2.png"), "reward": [], "quest": []}, 
	9: {"title": "TENDERFOOT V", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges2.png"), "reward": [], "quest": []}, 
	10: {"title": "SECOND CLASS SCOUT", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges3.png"), "reward": ["title_rank_10"], "quest": ["", "lake", 10, 100, 400]}, 
	11: {"title": "SECOND CLASS SCOUT II", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges3.png"), "reward": [], "quest": []}, 
	12: {"title": "SECOND CLASS SCOUT III", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges3.png"), "reward": [], "quest": []}, 
	13: {"title": "SECOND CLASS SCOUT IV", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges3.png"), "reward": [], "quest": []}, 
	14: {"title": "SECOND CLASS SCOUT V", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges3.png"), "reward": [], "quest": []}, 
	15: {"title": "FIRST CLASS SCOUT", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges4.png"), "reward": ["title_rank_15"], "quest": ["", "deep", 5, 100, 500]}, 
	16: {"title": "FIRST CLASS SCOUT II", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges4.png"), "reward": [], "quest": []}, 
	17: {"title": "FIRST CLASS SCOUT III", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges4.png"), "reward": [], "quest": []}, 
	18: {"title": "FIRST CLASS SCOUT IV", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges4.png"), "reward": [], "quest": []}, 
	19: {"title": "FIRST CLASS SCOUT V", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges4.png"), "reward": [], "quest": []}, 
	20: {"title": "STAR SCOUT", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges5.png"), "reward": ["title_rank_20"], "quest": ["", "ocean", 10, 150, 600]}, 
	21: {"title": "STAR SCOUT II", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges5.png"), "reward": [], "quest": []}, 
	22: {"title": "STAR SCOUT III", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges5.png"), "reward": [], "quest": []}, 
	23: {"title": "STAR SCOUT IV", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges5.png"), "reward": [], "quest": []}, 
	24: {"title": "STAR SCOUT V", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges5.png"), "reward": [], "quest": []}, 
	25: {"title": "LIFE SCOUT", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges6.png"), "reward": ["title_rank_25"], "quest": ["", "cave", 5, 150, 700]}, 
	26: {"title": "LIFE SCOUT II", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges6.png"), "reward": [], "quest": []}, 
	27: {"title": "LIFE SCOUT III", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges6.png"), "reward": [], "quest": []}, 
	28: {"title": "LIFE SCOUT IV", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges6.png"), "reward": [], "quest": []}, 
	29: {"title": "LIFE SCOUT V", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges6.png"), "reward": [], "quest": []}, 
	30: {"title": "EAGLE SCOUT", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges7.png"), "reward": ["title_rank_30"], "quest": ["", "deep", 15, 200, 800]}, 
	31: {"title": "EAGLE SCOUT II", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges7.png"), "reward": [], "quest": []}, 
	32: {"title": "EAGLE SCOUT III", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges7.png"), "reward": [], "quest": []}, 
	33: {"title": "EAGLE SCOUT IV", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges7.png"), "reward": [], "quest": []}, 
	34: {"title": "EAGLE SCOUT V", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges7.png"), "reward": [], "quest": []}, 
	35: {"title": "SURVIVAL EXPERT", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges8.png"), "reward": ["title_rank_35"], "quest": ["", "lake", 30, 250, 900]}, 
	36: {"title": "SURVIVAL EXPERT II", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges8.png"), "reward": [], "quest": []}, 
	37: {"title": "SURVIVAL EXPERT III", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges8.png"), "reward": [], "quest": []}, 
	38: {"title": "SURVIVAL EXPERT IV", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges8.png"), "reward": [], "quest": []}, 
	39: {"title": "SURVIVAL EXPERT V", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges8.png"), "reward": [], "quest": []}, 
	40: {"title": "PACK LEADER", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges9.png"), "reward": ["title_rank_40"], "quest": ["", "cave", 20, 350, 1000]}, 
	41: {"title": "PACK LEADER II", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges9.png"), "reward": [], "quest": []}, 
	42: {"title": "PACK LEADER III", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges9.png"), "reward": [], "quest": []}, 
	43: {"title": "PACK LEADER IV", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges9.png"), "reward": [], "quest": []}, 
	44: {"title": "PACK LEADER V", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges9.png"), "reward": [], "quest": []}, 
	45: {"title": "HEADMASTER", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges10.png"), "reward": ["title_rank_45"], "quest": ["", "ocean", 30, 500, 1200]}, 
	46: {"title": "HEADMASTER II", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges10.png"), "reward": [], "quest": []}, 
	47: {"title": "HEADMASTER III", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges10.png"), "reward": [], "quest": []}, 
	48: {"title": "HEADMASTER IV", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges10.png"), "reward": [], "quest": []}, 
	49: {"title": "HEADMASTER V", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges10.png"), "reward": [], "quest": []}, 
	50: {"title": "VOYAGER", "icon": preload("res://Assets/Textures/UI/RankBadges/rank_badges11.png"), "reward": ["title_rank_50"], "quest": []}, 
}
const FALLBACK_ITEM = {"id": "empty_hand", "ref": 0, "size": 1.0, "quality": ITEM_QUALITIES.NORMAL, "tags": []}
const FALLBACK_COSM = {"species": "species_cat", "pattern": "pattern_none", "primary_color": "pcolor_white", "secondary_color": "scolor_tan", "hat": "hat_none", "undershirt": "shirt_none", "overshirt": "overshirt_none", "title": "title_rank_1", "bobber": "bobber_default", "eye": "eye_halfclosed", "nose": "nose_cat", "mouth": "mouth_default", "accessory": [], "tail": "tail_cat", "legs": "legs_none"}
const DEFAULT_GUITAR_SHAPES = [
	[[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]], 
	[[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]], 
	[[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]], 
	[[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]], 
	[[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]], 
	[[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]], 
	]
const VALID_JOURNAL_KEYS = ["lake", "ocean", "rain", "water_trash", "alien", "void"]

const LETTER_CLOSINGS = ["From, ", "With Love, ", "Best Regards, ", "Talk Soon, ", "Watch out, ", "I'm approaching. ", ":3, "]

var voice_bank = {}

var stored_save = {}

var cosmetics_equipped = {}
var cosmetics_unlocked = []
var new_cosmetics = []
var inventory = []
var locked_refs = []
var hotbar = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0}
var money = 30 setget _set_cash
var badge_level = 1
var badge_xp = 0
var last_recorded_time = {}
var players_muted = []
var players_hidden = []
var journal_logs = {
	"lake": {}, 
	"ocean": {}, 
	"rain": {}, 
}

var voice_speed = 5
var voice_pitch = 1.5

var outbound_mail = []
var inbound_mail = []

var props_placed = []

var bait_selected = ""
var bait_unlocked = ["", "worms"]
var bait_inv = {
	"": 0, 
	"worms": 10, 
}

var lure_selected = ""
var lure_unlocked = [""]

var rod_power_level = 0
var rod_speed_level = 0
var rod_chance_level = 0
var rod_luck_level = 0

var buddy_level = 0
var buddy_speed = 0

var saved_tags = []
var saved_aqua_fish = {"id": "empty", "ref": 0, "size": 50.0, "quality": ITEM_QUALITIES.NORMAL}
var current_shop = []
var time_check = 60
var max_bait = 5
var current_quests = {}
var missing_quests = []
var completed_quests = []

var loan_level = 0
var loan_left = 1000
var cash_extra = 0


var fish_caught = 0
var cash_total = 0

var player_options = {}

var DEV_CHEAT_MODE = false
var VERSION_MATCH = false
var FORCE_TUTORIAL = true
var USING_SAVE = false

var cosmetic_reset_lock = false

var original_mouse_position = Vector2()
var player_saved_position = Vector3()
var player_saved_zone = ""
var player_saved_zone_owner = - 1

var punching_alot = false

var guitar_shapes = []

signal _inventory_refresh
signal _hotbar_refresh
signal _letter_update
signal _mute_update
signal _bait_update
signal _shop_update
signal _item_equip
signal _shop_refresh
signal _journal_update
signal _quest_update
signal _stamina_update
signal _upgrade_update
signal _xp_add(amt, lvl, total)
signal _notif_send(text, type)
signal _force_menu_close
signal _clear_all_props
signal _wag_toggle
signal _clear_new
signal _rain_toggle(toggle)
signal _prop_update
signal _place_prop(id)
signal _aquarium_update
signal _help_update(text)
signal _float_number
signal _hide_hud_toggle
signal _chalk_draw(pos)
signal _chalk_update(pos)
signal _chalk_send
signal _chalk_recieve(data, id)
signal _loan_update
signal _saved
signal _play_sfx(id)
signal _play_guitar(string, fret, volume)
signal _hammer_guitar(string, fret)
signal _return_to_spawn
signal _kiss
signal _punched(from, type)
signal _item_removal(ref)
signal _request_item_choice
signal _return_item_choice(choices)
signal _update_props

signal _save_reset

signal _request_arena_start
signal _arena_start
signal _arena_over
signal _arena_join(item_data)
signal _arena_death
signal _arena_tick
signal _arena_cashout(data)






func _reset_save():
	print("Save Reset")
	inventory = []
	locked_refs = []
	saved_tags = []
	hotbar = {0: 1, 1: 0, 2: 0, 3: 0, 4: 0}
	cosmetics_unlocked = []
	cosmetics_equipped = FALLBACK_COSM.duplicate()
	money = 25 + cash_extra
	badge_level = 1
	badge_xp = 0
	bait_selected = "worms"
	lure_selected = ""
	max_bait = 5
	bait_inv = {"": 0, 
				"worms": 5, 
				"cricket": 0, 
				"leech": 0, 
				"minnow": 0, 
				"squid": 0, 
				"nautilus": 0, 
				}
	bait_unlocked = ["", "worms"]
	lure_unlocked = [""]
	last_recorded_time = OS.get_time(true)
	last_recorded_time["minute"] = floor(last_recorded_time["minute"] / 5.0) * 5
	last_recorded_time["second"] = 0
	saved_aqua_fish = {"id": "empty", "size": 1.0, "ref": 0, "quality": ITEM_QUALITIES.NORMAL}
	rod_power_level = 0
	rod_speed_level = 0
	rod_chance_level = 0
	rod_luck_level = 0
	buddy_level = 0
	buddy_speed = 0
	inbound_mail.clear()
	outbound_mail.clear()
	loan_left = LOAN_DATA[0]
	loan_level = 0
	guitar_shapes = DEFAULT_GUITAR_SHAPES.duplicate(true)
	voice_pitch = 1.5
	voice_speed = 5
	
	fish_caught = 0
	cash_total = 25
	
	_reset_journal()
	
	current_quests = {}
	completed_quests = []
	
	
	_add_quest("Catch Lake Fish", "catch_type", "lake", 5, 25, [], "res://Assets/Textures/Creatures/creature_main1.png", - 1, false)
	_add_quest("Catch Ocean Fish", "catch_type", "ocean", 5, 30, [], "res://Assets/Textures/Creatures/creature_main32.png", - 1, false)
	_add_quest("Catch Creatures that are Tiny, or Microscopic", "catch_small", "", 5, 25, [], "res://Assets/Textures/Creatures/creature_main18.png", - 1, false)
	_add_quest("Catch Creatures that Massive, Gigantic, or Colossal", "catch_big", "", 5, 25, [], "res://Assets/Textures/Creatures/creature_main26.png", - 1, false)
	_add_quest("Catch Treasure Chests", "catch_treasure", "", 1, 25, [], "res://Assets/Textures/Items/toolicons4.png", - 1, false)
	_add_quest("Catch Fish in the Rain", "catch_rain", "", 5, 25, [], "res://Assets/Textures/Creatures/creature_main13.png", - 1, false)
	_add_quest("Catch High Tier Fish", "catch_hightier", "", 5, 25, [], "res://Assets/Textures/Creatures/creature_main29.png", - 1, false)
	
	
	
	
	
	
	
	
	_add_quest("Catch Sturgeon", "catch", "fish_lake_sturgeon", [1, 5], 25, ["undershirt_graphic_tshirt_milf", "overshirt_overall_green"], "res://Assets/Textures/Creatures/creature_main8.png", 2)
	_add_quest("Catch Catfish", "catch", "fish_lake_catfish", [1, 5], 25, ["title_catfisher", "overshirt_overall_tan"], "res://Assets/Textures/Creatures/creature_main9.png", 2)
	_add_quest("Catch Koi", "catch", "fish_lake_koi", [1, 5], 25, ["title_koiboy", "eye_plead"], "res://Assets/Textures/Creatures/creature_main10.png", 2)
	_add_quest("Catch Frog", "catch", "fish_lake_frog", [1, 5], 25, ["title_cozy", "accessory_rain_boots_green"], "res://Assets/Textures/Creatures/creature_main17.png", 2)
	_add_quest("Catch Turtle", "catch", "fish_lake_turtle", [1, 5], 25, ["nose_v", "overshirt_vest_olive"], "res://Assets/Textures/Creatures/creature_main20.png", 2)
	_add_quest("Catch Toad", "catch", "fish_lake_toad", [1, 5], 25, ["title_critter", "mouth_smirk"], "res://Assets/Textures/Creatures/creature_main21.png", 2)
	_add_quest("Catch Leech", "catch", "fish_lake_leech", [1, 5], 25, ["title_nightcrawler", "$prop_bush"], "res://Assets/Textures/Creatures/creature_main24.png", 2)
	_add_quest("Catch Muskellunge", "catch", "fish_lake_muskellunge", [1, 5], 25, ["undershirt_graphic_tshirt_threewolves", "title_musky"], "res://Assets/Textures/Creatures/creature_main26.png", 2)
	_add_quest("Catch Gar", "catch", "fish_lake_gar", [1, 5], 25, ["hat_bucket_tan", "overshirt_overall_olive"], "res://Assets/Textures/Creatures/creature_main29.png", 2)
	_add_quest("Catch Axolotl", "catch", "fish_lake_axolotl", [1, 5], 25, ["nose_booger", "hat_cowboyhat_pink"], "res://Assets/Textures/Creatures/creature_main30.png", 2)
	_add_quest("Catch Alligator", "catch", "fish_lake_alligator", [1, 5], 25, ["hat_bucket_green", "hat_cowboyhat_black"], "res://Assets/Textures/Creatures/creature_main31.png", 2)
	_add_quest("Catch King Salmon", "catch", "fish_lake_kingsalmon", [1, 5], 25, ["title_king", "hat_crown"], "res://Assets/Textures/Creatures/creature_main32.png", 2)
	_add_quest("Catch Bull Shark", "catch", "fish_lake_bullshark", [1, 5], 25, ["accessory_eyepatch", "overshirt_vest_green"], "res://Assets/Textures/Creatures/creature_main33.png", 2)
	_add_quest("Catch Pupfish", "catch", "fish_lake_pupfish", [1, 5], 25, ["title_pup", "$prop_rock"], "res://Assets/Textures/Creatures/creature_main34.png", 2)
	_add_quest("Catch Mooneye", "catch", "fish_lake_mooneye", [1, 5], 25, ["mouth_none", "mouth_dead"], "res://Assets/Textures/Creatures/creature_main35.png", 2)
	_add_quest("Catch Golden Bass", "catch", "fish_lake_golden_bass", [1, 5], 25, ["title_goldenbass", "accessory_shades_gold"], "res://Assets/Textures/Creatures/creature_main36.png", 2)
	
	_add_quest("Catch Eel", "catch", "fish_ocean_eel", [1, 5], 25, ["undershirt_graphic_tshirt_dare", "eye_serious"], "res://Assets/Textures/Creatures/creature_main55.png", 2)
	_add_quest("Catch Sawfish", "catch", "fish_ocean_sawfish", [1, 5], 25, ["nose_round", "title_shithead"], "res://Assets/Textures/Creatures/creature_main56.png", 2)
	_add_quest("Catch Swordfish", "catch", "fish_ocean_swordfish", [1, 5], 25, ["title_strongestwarrior", "overshirt_overall_grey"], "res://Assets/Textures/Creatures/creature_main61.png", 2)
	_add_quest("Catch Hammerhead Shark", "catch", "fish_ocean_hammerhead_shark", [1, 5], 25, ["title_sharkbait", "overshirt_overall_brown"], "res://Assets/Textures/Creatures/creature_main62.png", 2)
	_add_quest("Catch Octopus", "catch", "fish_ocean_octopus", [1, 5], 25, ["title_pretty", "*pcolor_pink_special"], "res://Assets/Textures/Creatures/creature_main65.png", 2)
	_add_quest("Catch Seahorse", "catch", "fish_ocean_seahorse", [1, 5], 25, ["undershirt_graphic_tshirt_burger", "mouth_chewing"], "res://Assets/Textures/Creatures/creature_main66.png", 2)
	_add_quest("Catch Manta Ray", "catch", "fish_ocean_manta_ray", [1, 5], 25, ["title_majestic", "overshirt_vest_grey"], "res://Assets/Textures/Creatures/creature_main69.png", 2)
	_add_quest("Catch Coalacanth", "catch", "fish_ocean_coalacanth", [1, 5], 25, ["title_ancient", "*pcolor_stone_special"], "res://Assets/Textures/Creatures/creature_main70.png", 2)
	_add_quest("Catch Great White Shark", "catch", "fish_ocean_greatwhiteshark", [1, 5], 25, ["title_elite", "overshirt_vest_tan"], "res://Assets/Textures/Creatures/creature_main71.png", 2)
	_add_quest("Catch Man O' War", "catch", "fish_ocean_manowar", [1, 5], 25, ["mouth_stitch", "mouth_monster"], "res://Assets/Textures/Creatures/creature_main72.png", 2)
	_add_quest("Catch Sea Turtle", "catch", "fish_ocean_sea_turtle", [1, 5], 25, ["title_dude", "eye_herbal"], "res://Assets/Textures/Creatures/creature_main73.png", 2)
	_add_quest("Catch Whale", "catch", "fish_ocean_whale", [1, 5], 25, ["mouth_shocked", "overshirt_vest_black"], "res://Assets/Textures/Creatures/creature_main74.png", 2)
	_add_quest("Catch Squid", "catch", "fish_ocean_squid", [1, 5], 25, ["eye_scribble", "*pcolor_midnight_special"], "res://Assets/Textures/Creatures/creature_main75.png", 2)
	_add_quest("Catch Golden Ray", "catch", "fish_ocean_golden_manta_ray", [1, 5], 25, ["title_goldenray", "accessory_goldsparkle_particles"], "res://Assets/Textures/Creatures/creature_main76.png", 2)
	
	_add_quest("Catch Unidentified Fish Object", "catch", "fish_alien_dog", [1, 5], 25, ["eye_alien", "accessory_alien_particles"], "res://Assets/Textures/Creatures/alien_creature1.png", 2)
	
	_add_quest("Catch Helicoprion", "catch", "fish_rain_heliocoprion", [1, 5], 25, ["title_special", "mouth_rabid"], "res://Assets/Textures/Creatures/creature_main80.png", 2)
	_add_quest("Catch Leedsichthys", "catch", "fish_rain_leedsichthys", [1, 5], 25, ["undershirt_graphic_tshirt_soup", "title_problematic"], "res://Assets/Textures/Creatures/creature_bigfish.png", 2)
	
	
	_add_item("empty_hand", 0, 1.0, 0, [], false)
	_add_item("fishing_rod_simple", 1)
	
	cosmetic_reset_lock = true
	_unlock_cosmetic("eye_halfclosed")
	_unlock_cosmetic("eye_spiral")
	_unlock_cosmetic("eye_closed")
	_unlock_cosmetic("eye_dot")
	_unlock_cosmetic("eye_sideeye")
	_unlock_cosmetic("eye_tired")
	_unlock_cosmetic("eye_x")
	_unlock_cosmetic("eye_drained")
	_unlock_cosmetic("eye_focused")
	_unlock_cosmetic("eye_glance")
	_unlock_cosmetic("eye_jolly")
	_unlock_cosmetic("eye_glamor")
	_unlock_cosmetic("eye_sassy")
	_unlock_cosmetic("eye_annoyed")
	_unlock_cosmetic("eye_glamor")
	_unlock_cosmetic("eye_sassy")
	_unlock_cosmetic("eye_annoyed")
	_unlock_cosmetic("eye_dreaming")
	
	_unlock_cosmetic("mouth_default")
	_unlock_cosmetic("mouth_toothy")
	_unlock_cosmetic("mouth_aloof")
	_unlock_cosmetic("mouth_animal")
	_unlock_cosmetic("mouth_glad")
	_unlock_cosmetic("mouth_squiggle")
	_unlock_cosmetic("mouth_tongue")
	_unlock_cosmetic("mouth_toothy")
	
	_unlock_cosmetic("nose_cat")
	_unlock_cosmetic("nose_dog")
	_unlock_cosmetic("nose_pink")
	_unlock_cosmetic("nose_whisker")
	_unlock_cosmetic("nose_none")
	
	_unlock_cosmetic("species_cat")
	_unlock_cosmetic("species_dog")
	
	_unlock_cosmetic("tail_none")
	_unlock_cosmetic("tail_cat")
	_unlock_cosmetic("tail_dog_thin")
	_unlock_cosmetic("tail_dog_fluffy")
	_unlock_cosmetic("tail_dog_short")
	_unlock_cosmetic("tail_fox")
	
	_unlock_cosmetic("legs_none")
	
	_unlock_cosmetic("shirt_none")
	
	_unlock_cosmetic("overshirt_none")
	
	_unlock_cosmetic("hat_none")
	
	var colors = ["white", "tan", "brown", "red", "maroon", "grey", "green", "blue", "purple", "salmon", "yellow", "black", "teal", "olive", "orange"]
	for t in ["pcolor_", "scolor_"]:
		for c in colors: _unlock_cosmetic(t + c)
	
	_unlock_cosmetic("pattern_none")
	_unlock_cosmetic("pattern_collie")
	_unlock_cosmetic("pattern_tux")
	_unlock_cosmetic("pattern_spotted")
	_unlock_cosmetic("pattern_calico")
	
	_unlock_cosmetic("title_none")
	_unlock_cosmetic("title_rank_1")
	
	_unlock_cosmetic("bobber_default")
	cosmetic_reset_lock = false
	
	
	_special_player_unlocks()
	_unlock_defaults()
	_missing_quest_check()
	
	if DEV_CHEAT_MODE:
		for cosmetic in Globals.cosmetic_data.keys():
			_unlock_cosmetic(cosmetic)
		for lure in LURE_DATA.keys():
			lure_unlocked.append(lure)
		money = 999999
	
	yield(get_tree().create_timer(0.25), "timeout")
	emit_signal("_save_reset")

func _special_player_unlocks(full_reset = true):
	match Network.STEAM_ID:
		76561198298932199:
			_unlock_cosmetic("overshirt_sweatshirt_purple")
			_unlock_cosmetic("title_stupididiotbaby")
			if full_reset: money += 200
		76561198108125836:
			_unlock_cosmetic("undershirt_graphic_tshirt_threewolves")
			_unlock_cosmetic("title_imnormal")
			if full_reset: _add_item("guitar_stickers")
			if full_reset: money += 200
		76561198109913387:
			_unlock_cosmetic("accessory_stink_particles")
			_unlock_cosmetic("title_bipedalanimaldrawer")
			if full_reset: money += 200
		76561198116925213:
			_unlock_cosmetic("undershirt_graphic_tshirt_dare")
			_unlock_cosmetic("pcolor_west")
			_unlock_cosmetic("mouth_toothier")
			_unlock_cosmetic("title_lamedev")
			_unlock_cosmetic("title_lamedev_real")
			_unlock_cosmetic("title_stupididiotbaby")
			_unlock_cosmetic("title_bipedalanimaldrawer")
			_unlock_cosmetic("title_imnormal")
			_unlock_cosmetic("title_hazard")
			_unlock_cosmetic("title_nitrousoxide")
			if full_reset: money += 200
		76561198048418963:
			_unlock_cosmetic("accessory_bandaid")
			_unlock_cosmetic("title_admiral")
			if full_reset: money += 200
		76561198075315616:
			_unlock_cosmetic("pcolor_midnight_special")
			_unlock_cosmetic("scolor_midnight_special")
			_unlock_cosmetic("overshirt_labcoat")
			_unlock_cosmetic("title_cadaverdog")
			if full_reset: money += 200
		76561199104328044:
			_unlock_cosmetic("title_hazard")
		76561199179487223:
			_unlock_cosmetic("title_nitrousoxide")
		76561198353061650:
			_unlock_cosmetic("title_igloo")
		76561198169378907:
			_unlock_cosmetic("title_zed")
		76561198816340850:
			_unlock_cosmetic("title_specialforces")
		76561198215486940:
			_unlock_cosmetic("title_candy")

func _add_saved_tag(new_tag):
	if not saved_tags.has(new_tag):
		saved_tags.append(new_tag)




func _unlock_defaults():
	yield(get_tree().create_timer(0.15), "timeout")
	
	
	
	
	
	_special_player_unlocks(false)

func _missing_quest_check():
	
	
	missing_quests = ["Catch CREATURE"]
	
	for key in current_quests.keys():
		var quest = current_quests[key]
		if missing_quests.has(quest.title):
			missing_quests.erase(quest.title)
	
	for quest in missing_quests:
		if completed_quests.has(quest): continue
		
		print("MISSING QUEST ", quest)
		match quest:
			"Catch CREATURE": _add_quest("Catch CREATURE", "catch", "fish_void_voidfish", [1, 5], 25, ["title_freaky", "eye_wobble"], "res://Assets/Textures/Creatures/VoidFish/void_fish_animated.tres", 2)
	
	missing_quests.clear()
	
	
	var blacklist = [
		"Fill all Journal Entries in Normal Quality", 
		"Fill all Journal Entries in Shining Quality", 
		"Fill all Journal Entries in Glistening Quality", 
		"Fill all Journal Entries in Opulent Quality", 
		"Fill all Journal Entries in Radiant Quality", 
		"Fill all Journal Entries in Alpha Quality"]
	
	var quests_to_delete = []
	for key in current_quests.keys():
		var data = current_quests[key]
		if blacklist.has(data.title):
			quests_to_delete.append(key)
	
	for q in quests_to_delete:
		current_quests.erase(q)





func _mute_player(id):
	if players_muted.has(id): players_muted.erase(id)
	else: players_muted.append(id)
	emit_signal("_mute_update")

func _hide_player(id):
	if players_hidden.has(id):
		players_hidden.erase(id)
		PlayerData._send_notification("Player un-blocked.")
	else:
		players_hidden.append(id)
		PlayerData._send_notification("Player blocked.")
	emit_signal("_mute_update")

func _unhide_player(id):
	if not players_hidden.has(id): return
	players_hidden.erase(id)
	PlayerData._send_notification("Player un-blocked.")
	emit_signal("_mute_update")





func _add_item(item_id, forced_id = - 1, size = 1.0, quality = ITEM_QUALITIES.NORMAL, tags = [], use_filter = true):
	if inventory.size() >= 10000:
		PlayerData._send_notification("inventory full, item trashed!", 1)
		return - 1
	
	if item_id == "fishing_rod_skeleton": Network._unlock_achievement("spectral_rod")
	
	
	if not Globals.item_data.keys().has(item_id):
		print("Item Does Not Exist.")
		return
	
	
	var item_data = Globals.item_data[item_id]["file"]
	if item_data.stackable:
		var stack_size = item_data.max_stacks
		for item in inventory:
			var has_count_key = item.keys().has("count")
			if item["id"] == item_id and ( not has_count_key or (has_count_key and item["count"] < stack_size)):
				if not has_count_key: item["count"] = 1
				item["count"] += 1
				emit_signal("_inventory_refresh")
				return item["ref"]
	
	randomize()
	var ref = randi() if not (forced_id is int) or forced_id == - 1 else forced_id
	var entry = {"id": item_id, "size": size, "ref": ref, "quality": quality, "tags": tags}
	entry = _validate_item_safety(entry, use_filter)
	inventory.append(entry)
	emit_signal("_inventory_refresh")
	return ref

func _validate_item_safety(item_data, filter_unobtainable = true):
	var FALLBACK_ITEM = {"id": "fish_lake_salmon", "ref": randi(), "size": 60.0, "quality": 0, "tags": [], "custom_name": ""}
	
	if not (item_data is Dictionary):
		return FALLBACK_ITEM
	
	var required_keys = ["id", "ref", "size", "quality"]
	for key in required_keys:
		if not item_data.keys().has(key):
			return FALLBACK_ITEM
	
	var item_id = str(item_data.id)
	var size = item_data.size
	var quality = item_data.quality
	var ref = item_data.ref
	var tags = item_data.tags if item_data.keys().has("tags") else []
	var custom_name = item_data.custom_name if item_data.keys().has("custom_name") else ""
	var count = item_data.count if item_data.keys().has("count") else 1
	
	
	if not Globals.item_data.keys().has(item_id):
		print("Item Does Not Exist.")
		return FALLBACK_ITEM
	
	
	if filter_unobtainable:
		var idata = Globals.item_data[item_id]["file"]
		if idata.unobtainable:
			return FALLBACK_ITEM
	
	
	if not (size is float or size is int): size = 60.0
	else: size = clamp(size, 0.01, 999999999.0)
	
	if not (quality is int): quality = 0
	else: quality = clamp(quality, 0, PlayerData.QUALITY_DATA.size() - 1)
	
	if not (ref is int): ref = randi()
	if ref == 0 and filter_unobtainable: ref = randi()
	
	if not (tags is Array): tags = []
	else:
		var new_tags = []
		for i in tags: new_tags.append(str(tags[i]))
		tags.clear()
		tags = new_tags
	
	custom_name = str(custom_name).left(28)
	custom_name = custom_name.replace("[", "")
	custom_name = custom_name.replace("]", "")
	
	count = clamp(count, 1, 99)
	
	
	return {"id": item_id, "ref": ref, "size": size, "quality": quality, "tags": tags, "custom_name": custom_name, "count": count}

func _validate_inventory():
	var new_inv = []
	for item in inventory:
		var final = item
		if item.ref != 0:
			final = _validate_item_safety(item)
		new_inv.append(final)

func _add_raw_item(data, save = true):
	if inventory.size() >= 10000:
		PlayerData._send_notification("inventory full, item trashed!", 1)
		return - 1
	
	data = _validate_item_safety(data)
	inventory.append(data)
	if save:
		emit_signal("_inventory_refresh")

func _remove_item(item_id, call_equip = true, call_refresh = true, remove_all = false):
	var item
	for i in inventory:
		if i["ref"] == item_id:
			item = i
	
	if not item:
		print("No Item Found")
		return
	
	var has_stacks = false
	
	
	if item.keys().has("count") and item["count"] > 1:
		item["count"] -= 1
		has_stacks = true
	
	if remove_all:
		item["count"] = 0
		has_stacks = false
	
	
	
	if not has_stacks:
		inventory.erase(item)
	
		for key in hotbar.keys():
			if hotbar[key] == item_id: hotbar[key] = 0
		
		locked_refs.erase(item_id)
		
		if call_equip: emit_signal("_item_removal", item_id)
	
	if call_refresh:
		emit_signal("_inventory_refresh")
		emit_signal("_hotbar_refresh")

func _lock_item(item_ref):
	if not locked_refs.has(item_ref):
		if locked_refs.size() > 100:
			_send_notification("cannot have more than 100 favorite items", 1)
			return
		
		_send_notification("favorited item")
		print("Item ", item_ref, " locked")
		locked_refs.append(item_ref)
	else:
		_send_notification("un-favorited item", 1)
		print("Item ", item_ref, " unlocked")
		locked_refs.erase(item_ref)
	
	emit_signal("_hotbar_refresh")

func _bind_hotbar_slot(hotbarslot, slot):
	var ref = inventory[slot]["ref"]
	
	if hotbar[hotbarslot] == ref: ref = 0
	else:
		for i in hotbar.keys():
			if hotbar[i] == ref: hotbar[i] = 0
	
	print(hotbar, " ", hotbar[hotbarslot], " ", ref)
	
	hotbar[hotbarslot] = ref
	emit_signal("_hotbar_refresh")

func _find_item_code(ref):
	for item in inventory:
		if item["ref"] == ref:
			return item
	return PlayerData.FALLBACK_ITEM

func _item_exists(ref):
	for item in inventory:
		if item["ref"] == ref:
			return true
	return false

func _unlock_cosmetic(id):
	if cosmetics_unlocked.has(id): return
	cosmetics_unlocked.append(id)
	
	if not cosmetic_reset_lock:
		new_cosmetics.append(id)
	
		var data = Globals.cosmetic_data[id]["file"]
		_send_notification("cosmetic " + str(data.name).to_lower() + " unlocked!")

func _change_cosmetic(type, to):
	print("Changing cosmetic, ", cosmetics_equipped)
	cosmetics_equipped[type] = to

func _change_accessory(id):
	print("Changing cosmetic, ", cosmetics_equipped)
	if cosmetics_equipped["accessory"].has(id):
		cosmetics_equipped["accessory"].erase(id)
	elif cosmetics_equipped["accessory"].size() < 4:
		cosmetics_equipped["accessory"].append(id)

func _get_unowned_cosmetic():
	print("getting unowned cosmetic")
	
	randomize()
	var cosmetic_list = Globals.cosmetic_data.keys().duplicate()
	cosmetic_list.shuffle()
	for cosmetic in cosmetic_list:
		if cosmetics_unlocked.has(cosmetic): continue
		var data = Globals.cosmetic_data[cosmetic]["file"]
		if not data.chest_reward: continue
		
		return cosmetic
	return null

func _use_bait(bait_id):
	if bait_id == "" or bait_inv[bait_id] <= 0: return
	bait_inv[bait_id] -= 1
	if bait_inv[bait_id] <= 0:
		bait_selected = ""
	emit_signal("_bait_update")

func _get_item_name(ref):
	var size_prefix = {
		0.1: "Microscopic ", 
		0.25: "Tiny ", 
		0.5: "Small ", 
		1.0: "", 
		1.5: "Large ", 
		1.75: "Huge ", 
		2.25: "Massive ", 
		2.75: "Gigantic ", 
		3.25: "Colossal ", 
	}
	
	var data = _find_item_code(ref)
	var average = Globals.item_data[data["id"]]["file"].average_size
	var calc = data["size"] / average
	var prefix = ""
	
	for p in size_prefix.keys():
		if p > calc: break
		prefix = size_prefix[p]
	
	var item_name = Globals.item_data[data["id"]]["file"].item_name
	if data.keys().has("custom_name") and data["custom_name"] != "":
		prefix = ""
		item_name = data["custom_name"]
		
		item_name = item_name.replace("[", "")
		item_name = item_name.replace("]", "")
		
		item_name = item_name + " (edit)"
	
	if data.keys().has("count") and data["count"] > 1:
		item_name = item_name + " (x" + str(data["count"]) + ")"
	
	var stars = ""
	for i in data["quality"]:
		stars = stars + "[img={valign}]res://Assets/Textures/UI/stars.png[/img]"
	if data["quality"] > 0: stars = stars + " "
	
	var quality = ""
	if QUALITY_DATA.has(data["quality"]):
		var d = QUALITY_DATA[data["quality"]]
		quality = stars + "[color=" + str(d.color) + "]" + d.name + "[/color]"
	
	return quality + prefix + "" + item_name

func _get_size_type(id, size):
	var size_prefix = {
		0.1: "microscopic", 
		0.25: "tiny", 
		0.5: "small", 
		1.0: "", 
		1.5: "large", 
		1.75: "huge", 
		2.25: "massive", 
		2.75: "gigantic", 
		3.25: "colossal", 
	}
	
	var average = Globals.item_data[id]["file"].average_size
	var calc = size / average
	var prefix = ""
	
	for p in size_prefix.keys():
		if p > calc: break
		prefix = size_prefix[p]
	return prefix

func _get_item_worth(ref, type = "money"):
	var size_prefix = {
		0.1: 1.75, 
		0.25: 0.6, 
		0.5: 0.8, 
		1.0: 1.0, 
		1.5: 1.5, 
		2.0: 2.5, 
		3.0: 4.25, 
	}
	
	var data = _find_item_code(ref)
	var average = Globals.item_data[data["id"]]["file"].average_size
	var calc = data["size"] / average
	var mult = 1.0
	
	for p in size_prefix.keys():
		if p > calc: break
		mult = size_prefix[p]
	
	var idata = Globals.item_data[data["id"]]["file"]
	var value = idata.sell_value
	if idata.generate_worth:
		var t = 1.0 + (0.25 * idata.tier)
		var w = idata.loot_weight
		value = pow(5 * t, 2.5 - w)
		
		if w < 0.4: value *= 1.1
		if w < 0.15: value *= 1.25
		if w < 0.05: value *= 1.5
	
	var worth = ceil(value * mult * PlayerData.QUALITY_DATA[data["quality"]].worth)
	if type == "credits" and data["fresh"] == false: worth = 0
	
	return worth

func _rename_item(ref, new_name):
	for item in inventory:
		if item["ref"] == ref:
			item["custom_name"] = str(new_name)
	emit_signal("_hotbar_refresh")
	emit_signal("_inventory_refresh")







func _send_letter(to, header, closing, body, items):
	randomize()
	var letter_id = randi()
	var data = {"letter_id": letter_id, "header": header, "closing": closing, "body": body, "items": items, "to": str(to), "from": str(Network.STEAM_ID), "user": str(Network.STEAM_USERNAME)}
	
	if to != Network.STEAM_ID:
		Network._send_P2P_Packet({"type": "letter_recieved", "data": data, "to": str(to)}, str(to), 2, Network.CHANNELS.GAME_STATE)
	else:
		_recieved_letter(data)
	
	emit_signal("_letter_update")
	
	for item in items:
		_remove_item(item["ref"], true, false, true)
	
	emit_signal("_inventory_refresh")
	emit_signal("_hotbar_refresh")
	_send_notification("letter sent!")

func _letter_was_denied():
	emit_signal("_inventory_refresh")
	emit_signal("_hotbar_refresh")
	emit_signal("_letter_update")
	_send_notification("your letter was denied!", 1)

func _letter_was_accepted():
	_send_notification("your letter was accepted!", 0)


func _recieved_letter(data):
	if OptionsMenu.mail_close == 1:
		_send_notification("incoming letter automatically denied!")
		return
	
	if inbound_mail.size() > 49:
		_send_notification("got a letter, but couldn't fit letter in mailbox!", 1)
		return
	
	var recieved_letter = {}
	recieved_letter["letter_id"] = randi()
	
	
	var header = str(data["header"]).left(32)
	recieved_letter["header"] = Marshalls.utf8_to_base64(header)
	
	
	var closing = str(data["closing"]).left(24)
	var valid_closing = LETTER_CLOSINGS.find(closing)
	if valid_closing == - 1: closing = "From, "
	recieved_letter["closing"] = closing
	
	
	var body = str(data["body"]).left(500)
	recieved_letter["body"] = Marshalls.utf8_to_base64(body)
	
	
	var items = []
	if data["items"] is Array:
		for item in data["items"]:
			items.append(_validate_item_safety(item))
			if items.size() > 49: break
	recieved_letter["items"] = items
	
	
	var to = str(Network.STEAM_ID)
	recieved_letter["to"] = to
	
	
	var from = "unknown"
	if typeof(data["from"]) is int: from = Network._get_username_from_id(int(data["from"]))
	recieved_letter["from"] = from
	
	inbound_mail.append(recieved_letter)
	emit_signal("_letter_update")
	_send_notification("letter recieved!")

func _accept_letter(letter_id):
	var data
	for letter in inbound_mail:
		if letter["letter_id"] == letter_id:
			data = letter
	if not data: return
	
	var valid = false
	for member in Network.LOBBY_MEMBERS:
		if str(member["steam_id"]) == data["to"]: valid = true
	
	var items = 0
	var item_cap = 20
	for item in data["items"]:
		_add_raw_item(item, false)
		
		items += 1
		if items > 20: break
	
	var from = data["from"]
	Network._send_P2P_Packet({"type": "letter_was_accepted"}, str(from), 2)
	
	inbound_mail.erase(data)
	
	emit_signal("_inventory_refresh")
	emit_signal("_hotbar_refresh")
	emit_signal("_letter_update")
	_send_notification("letter accepted!")

func _deny_letter(letter_id):
	var data
	for letter in inbound_mail:
		if letter["letter_id"] == letter_id:
			data = letter
	if not data: return
	
	var valid = false
	for member in Network.LOBBY_MEMBERS:
		if str(member["steam_id"]) == data["to"]: valid = true
	
	var from = data["from"]
	inbound_mail.erase(data)
	Network._send_P2P_Packet({"type": "letter_was_denied"}, str(from), 2)
	emit_signal("_letter_update")
	_send_notification("letter denied!")

func _is_base64_encoded(input_str):
	var base64_pattern = RegEx.new()
	var pattern = "^[A-Za-z0-9+/=]+$"
	var err = base64_pattern.compile(pattern)
	
	if err != OK:
		print("Regex Compile fucky wucky :/")
		return false
	
	var match_result = base64_pattern.search(input_str)
	
	if match_result != null:
		if input_str.length() % 4 != 0: return false
		
		if input_str.ends_with("==") and input_str.length() % 4 != 0:
			return false
		elif input_str.ends_with("=") and input_str.length() % 4 != 0:
			return false
		
		return true
	
	else:
		return false





func _refresh_shop():
	randomize()
	var item_count = 6
	var new_shop = []
	var cosmetics = Globals.cosmetic_data.keys()
	cosmetics.shuffle()
	
	for i in cosmetics:
		if Globals.cosmetic_data[i]["file"].in_rotation:
			new_shop.append(i)
			if new_shop.size() >= item_count: break
	
	current_shop = new_shop
	emit_signal("_shop_refresh")
	print("REFRESH SHOP!!!", new_shop)

func _get_time(shop = true):
	var ref = REFRESH_TIME if shop else QUEST_REFRESH_TIME
	
	var time = OS.get_time(true)
	var min_goal = ceil(time["minute"] / ref) * ref
	var min_diff = min_goal - time["minute"]
	var sec_diff = 60 - time["second"]
	
	return {"second": sec_diff, "minute": (ref - 1) + min_diff}






func _reset_journal():
	journal_logs = {
	"lake": {}, 
	"ocean": {}, 
	"rain": {}, 
	"water_trash": {}, 
	"alien": {}, 
	"void": {}}
	for item in Globals.item_data.keys():
		_log_item(item, 0.0, 0, true)
		
		if DEV_CHEAT_MODE:
			_log_item(item, 0.0, 0)
			_log_item(item, 0.0, 1)
			_log_item(item, 0.0, 2)
			_log_item(item, 0.0, 3)
			_log_item(item, 0.0, 4)
			_log_item(item, 0.0, 5)

func _journal_check():
	for key in VALID_JOURNAL_KEYS:
		if not journal_logs.keys().has(key):
			journal_logs[key] = {}
	
	for item in Globals.item_data.keys():
		_log_item(item, 0.0, 0, true)

func _log_item(item_id, size, quality = 0, new_entry = false):
	var data = Globals.item_data[item_id]["file"]
	var category = data.loot_table
	if not VALID_JOURNAL_KEYS.has(category) or data.category == "tool": return
	
	if new_entry:
		if journal_logs[category].keys().has(item_id):
			print("Creature Already exists in journal.")
			return
		
		var new = {}
		new["count"] = 0
		new["record"] = 0.0
		new["quality"] = []
		journal_logs[category][item_id] = new
	
	else:
		journal_logs[category][item_id]["count"] += 1
		if not journal_logs[category][item_id]["quality"].has(quality): journal_logs[category][item_id]["quality"].append(quality)
		
		
		var full = [0, 1, 2, 3, 4, 5]
		var has_caught_all = true
		
		for cat in journal_logs.keys():
			for ent in journal_logs[cat].keys():
				if journal_logs[cat][ent].count <= 0:
					has_caught_all = false
				
				for q in [0, 1, 2, 3, 4, 5]:
					if not journal_logs[cat][ent].quality.has(q) and full.has(q):
						full.erase(q)
						print("nope i dont have ", q)
		
		for f in full:
			_journal_achieve(f)
		if has_caught_all:
			_journal_achieve( - 1)
		
		if journal_logs[category][item_id]["record"] < size:
			journal_logs[category][item_id]["record"] = size
			
			emit_signal("_journal_update")
			return true
		else:
			emit_signal("_journal_update")
			return false

func _refill_bait(type = "", announce = true):
	if type == "":
		for bait in bait_unlocked:
			if bait == "": continue
			_refill_bait(bait, false)
		_send_notification("all bait refilled!")
		return
	
	if not bait_unlocked.has(type): return
	if bait_selected == "": bait_selected = type
	
	bait_inv[type] = max_bait
	emit_signal("_bait_update")
	if announce: _send_notification(BAIT_DATA[type].name + " bait refilled!")





func _refresh_sell():
	print("Refresh Favored Sell")
	var time = OS.get_time(true)
	
	var rng = RandomNumberGenerator.new()
	rng.seed = time["hour"] + time["minute"]
	
	var keys = Globals._get_loot_table_entries(["lake", "ocean"][randi() % 2])
	
	





func _refresh_quests():
	randomize()
	
	var q = {}
	for quest in current_quests.keys():
		if current_quests[quest]["progress"] >= current_quests[quest]["goal_amt"] or current_quests[quest]["temp"] == false:
			q[quest] = current_quests[quest]
	current_quests = q
	
	var lvl = badge_level
	var quest_amount = 1
	if lvl > 2: quest_amount = 2
	if lvl > 4: quest_amount = 3
	if lvl > 6: quest_amount = 4
	if lvl > 8: quest_amount = 5
	
	var tables = [["lake", 0]]
	if lvl > 2: tables.append(["lake", 1])
	if lvl > 5: tables.append(["lake", 2])
	
	for i in quest_amount:
		var new = {}
		var quest_id = randi()
		
		var tier = randi() % tables.size()
		var loot_table = tables[tier]
		
		var item = Globals._roll_loot_table(loot_table[0], loot_table[1])
		var diff = 0.8 + (i * 0.8)
		
		new["active"] = false
		new["type"] = 0
		new["goal_item"] = item
		new["type_based"] = ""
		new["goal_amt"] = ceil((Globals.item_data[item]["file"].loot_weight * 2.0) * diff)
		new["reward"] = stepify((22 * (tier + 1)) * diff, 5.0)
		new["xp"] = stepify((65 * (tier + 1)) * diff, 5.0)
		new["progress"] = 0
		new["temp"] = true
		
		current_quests[quest_id] = new
	
	emit_signal("_quest_update")
	print(current_quests)

func _add_rank_quest(data, start_active = false):
	var quest_id = randi()
	var new = {}
	new["active"] = start_active
	new["type"] = 1
	new["goal_item"] = "fish_lake_salmon" if data[0] == "" else data[0]
	new["type_based"] = data[1]
	new["goal_amt"] = data[2]
	new["reward"] = data[3]
	new["xp"] = data[4]
	new["progress"] = 0
	new["temp"] = false
	
	current_quests[quest_id] = new
	emit_signal("_quest_update")

func _add_quest(title, action, id = "", goal = 5, reward_base = 0.0, rewards = [], icon = null, max_level = - 1, hidden_until_level = true):
	var quest_id = randi()
	var new = {}
	new["title"] = title
	new["tier"] = 0
	new["action"] = action
	new["gold_reward"] = reward_base
	new["xp_reward"] = stepify(reward_base * 0.3, 5)
	new["rewards"] = rewards
	new["goal_id"] = id
	new["icon"] = icon
	new["progress"] = 0 if not DEV_CHEAT_MODE else 9999
	new["max_level"] = max_level
	new["hidden"] = hidden_until_level
	
	if goal is Array:
		new["goal_amt"] = goal[0]
		new["goal_array"] = goal
	else:
		new["goal_amt"] = goal
		new["goal_array"] = []
	
	current_quests[quest_id] = new
	emit_signal("_quest_update")

func _quest_progress(action, id = ""):
	for quest in current_quests.keys():
		var data = current_quests[quest]
		
		if action != data["action"]: continue
		
		var valid = true
		match action:
			"catch": if id != data["goal_id"]: valid = false
			"catch_type": if id != data["goal_id"]: valid = false
			"catch_big": if not ["massive", "gigantic", "colossal"].has(id): valid = false
			"catch_small": if not ["tiny", "microscopic"].has(id): valid = false
		
		if valid:
			print(action, "== ", data["action"], " i guess? ", id, " ", data["goal_id"])
			data["progress"] += 1
			if data["progress"] == data["goal_amt"]:
				completed_quests.append(data.title)
				_send_notification("quest '" + str(data.title) + "' complete! check the questboard for rewards")
				data["hidden"] = false
	
	print("UPDATEING QUESTS")
	emit_signal("_quest_update")

func _complete_quest(id):
	var data = current_quests[id]
	
	if data["progress"] < data["goal_amt"]: return
	
	_add_xp(data["xp_reward"])
	money += data["gold_reward"]
	
	data["progress"] -= data["goal_amt"]
	
	if data["rewards"].size() > data["tier"] and data["rewards"][data["tier"]] != "":
		var reward = data["rewards"][data["tier"]]
		if reward.begins_with("$"):
			reward.erase(0, 1)
			_add_item(reward)
		elif reward.begins_with("*"):
			reward.erase(0, 1)
			_unlock_cosmetic(reward)
			reward.erase(0, 1)
			_unlock_cosmetic("s" + reward)
		else:
			_unlock_cosmetic(reward)
	
	if data["tier"] < 9:
		data["tier"] += 1
		if data.goal_array.size() <= data.tier: data["goal_amt"] = ceil(data["goal_amt"] * 2)
		else: data["goal_amt"] = data.goal_array[data.tier]
		data["gold_reward"] = ceil(data["gold_reward"] * 2)
		data["xp_reward"] = ceil(data["xp_reward"] * 2)
	
	if data["max_level"] != - 1 and data["max_level"] <= data["tier"]:
		current_quests.erase(id)
	
	emit_signal("_quest_update")
	
	var node = Node2D.new()
	get_tree().get_root().add_child(node)
	emit_signal("_float_number", "quest claimed!", "#a4aa39", - 0.4, node.get_global_mouse_position())
	node.queue_free()
	
	GlobalAudio._play_sound("quest_win")

func _add_xp(amt):
	yield(get_tree().create_timer(0.5), "timeout")
	emit_signal("_xp_add", amt, badge_level, badge_xp)
	
	badge_xp += amt
	while badge_xp >= _get_xp_goal(badge_level) and badge_level < BADGE_LEVEL_DATA.size():
		badge_xp -= _get_xp_goal(badge_level)
		badge_level += 1
		get_tree().call_group("controlled_player", "_level_up")
		
		var username = str(Network.STEAM_USERNAME)
		username = username.replace("[", "")
		username = username.replace("]", "")
		
		Network._send_message("%u ranked up to rank " + str(badge_level) + "!", "ffeed5")
		_send_notification("you ranked up to rank " + str(badge_level) + "!")
		
		for reward in BADGE_LEVEL_DATA[badge_level]["reward"]:
			_unlock_cosmetic(reward)
		
		
		
		
		if badge_level >= 5: Network._unlock_achievement("rank_5")
		if badge_level >= 25: Network._unlock_achievement("rank_25")
		if badge_level >= 50: Network._unlock_achievement("rank_50")

func _get_xp_goal(level):
	return 100 + ((level - 1) * 50) + stepify(level * level * 0.15 * 75, 50)

func _get_level_data(level):
	return BADGE_LEVEL_DATA[level]





func _send_notification(text, type = 0):
	emit_signal("_notif_send", text, type)
	emit_signal("_play_sfx", "notification")




func _aquarium_update(new_fish, update = true):
	var old_fish = saved_aqua_fish
	saved_aqua_fish = new_fish.duplicate()
	emit_signal("_aquarium_update")
	
	if update:
		_remove_item(new_fish["ref"])
		if old_fish.id != "empty": _add_raw_item(old_fish)
		_send_notification("fish sent to aquarium!")





func _catch_fish():
	fish_caught += 1
	
	Network._unlock_achievement("catch_single_fish")
	Network._update_stat("fish_caught", fish_caught)
	if fish_caught >= 100: Network._unlock_achievement("catch_100_fish")

func _journal_achieve(f):
	match f:
		- 1:
			if not saved_tags.has("journal_all"):
				_add_saved_tag("journal_all")
				_send_notification("you has caught one of every fish!")
				Network._send_message("%u has caught one of every fish!", "ffeed5")
		0:
			if not saved_tags.has("journal_0"):
				_add_saved_tag("journal_0")
				_send_notification("you has caught one of every fish in NORMAL quality!")
				Network._send_message("%u has caught one of every fish in NORMAL quality!", "ffeed5")
				Network._unlock_achievement("journal_normal")
		1:
			if not saved_tags.has("journal_1"):
				_add_saved_tag("journal_1")
				_send_notification("you has caught one of every fish in SHINING quality!")
				Network._send_message("%u has caught one of every fish in SHINING quality!", "ffeed5")
				Network._unlock_achievement("journal_shining")
		2:
			if not saved_tags.has("journal_2"):
				_add_saved_tag("journal_2")
				_send_notification("you has caught one of every fish in GLISTENING quality!")
				Network._send_message("%u has caught one of every fish in GLISTENING quality!", "ffeed5")
				Network._unlock_achievement("journal_glistening")
		3:
			if not saved_tags.has("journal_3"):
				_add_saved_tag("journal_3")
				_send_notification("you has caught one of every fish in OPULENT quality!")
				Network._send_message("%u has caught one of every fish in OPULENT quality!", "ffeed5")
				Network._unlock_achievement("journal_opulent")
		4:
			if not saved_tags.has("journal_4"):
				_add_saved_tag("journal_4")
				_send_notification("you has caught one of every fish in RADIANT quality!")
				Network._send_message("%u has caught one of every fish in RADIANT quality!", "ffeed5")
				Network._unlock_achievement("journal_radiant")
		5:
			if not saved_tags.has("journal_5"):
				_add_saved_tag("journal_5")
				_send_notification("you has caught one of every fish in ALPHA quality!")
				Network._send_message("%u has caught one of every fish in ALPHA quality!", "ffeed5")
				Network._unlock_achievement("journal_alpha")

func _set_cash(amt):
	if amt >= 10000: Network._unlock_achievement("10k_cash")
	money = amt





func _validate_guitar_shapes():
	if guitar_shapes.size() != 6:
		guitar_shapes = DEFAULT_GUITAR_SHAPES.duplicate()
		print("Guitar Shapes Reset")
