extends WaterMain

@export var depth = - 0.006
@export var sand = true
@export var kills = true

func _ready():
	$sand.position.y = depth
	$sand.visible = sand
	$Area3D.monitorable = kills
