extends Area
class_name FishZone

export var chance_boost = 0.0
export var fish_type = "lake"
export var junk_mult = 1.0
export var alt_type = ""
export var alt_chance = 0.0
export var quality_boost = 1.0
export var type_lock = false

var id = - 1

func _ready():
	add_to_group("fish_zone")
