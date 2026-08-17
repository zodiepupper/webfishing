extends Resource
class_name ItemResource


var resource_type = "item"

@export var item_name = ""
@export var item_description = ""
@export var catch_blurb = ""
@export var item_is_hidden = false
@export var icon: Texture2D
@export var show_item = true
@export var item_scene: PackedScene
@export var show_scene = false
@export var uses_size = false
@export var mesh: Mesh
@export var action = ""
@export var action_params = []
@export var release_action = ""
@export var prop_code = ""
@export var help_text = ""
@export var arm_value = 0.0 # (float, 0.0, 0.4, 0.1)
@export var hold_offset = 0.0
@export var unselectable = false
@export var unrenamable = false
@export var category = "none" # (String, "none", "fish", "bug", "tool", "furniture")
@export var alive = true
@export var tier = 0


@export var catch_difficulty = 1.0
@export var catch_speed = 120.0
@export var loot_table = "none" # (String, "none", "lake", "ocean", "deep", "prehistoric", "bush_bug", "shoreline_bug", "tree_bug", "seashell", "trash", "water_trash", "rain", "alien", "metal", "void")
@export var loot_weight = 1.0
@export var average_size = 75.0
@export var sell_value = 5
@export var sell_multiplier = 1.0
@export var obtain_xp = 30
@export var generate_worth = true
@export var can_be_sold = true
@export var rare = false
@export var stackable = false
@export var max_stacks = 99
@export var unobtainable = false

@export var show_bait = false
@export var detect_item = false
