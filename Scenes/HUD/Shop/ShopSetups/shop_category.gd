extends Node

enum REPLACE_TYPE{NONE, ROTATING_SHOP, SELL, QUESTS, BAIT}
enum BOX_TYPE{GRID, VBOX, GRID_SMALL, SELL}

export var category_title = "category"
export (REPLACE_TYPE) var replace = REPLACE_TYPE.NONE
export (BOX_TYPE) var box_type = BOX_TYPE.GRID
export var loan_level_lock = - 1
export var collapse = false
export var include_sell_all = false
