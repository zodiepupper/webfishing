extends Area3D

@export var zone_travel = ""
@export var spawn_id = ""
@export var intro_text = ""

func _ready():
	add_to_group("death_transport_zone")
