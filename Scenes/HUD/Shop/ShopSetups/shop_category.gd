extends Node

enum REPLACE_TYPE{NONE, ROTATING_SHOP, SELL, QUESTS, BAIT}
enum BOX_TYPE{GRID, VBOX, GRID_SMALL, SELL}

@export var category_title = "category"
@export var replace: REPLACE_TYPE = REPLACE_TYPE.NONE
@export var box_type: BOX_TYPE = BOX_TYPE.GRID
@export var loan_level_lock = - 1
@export var collapse = false
@export var include_sell_all = false
