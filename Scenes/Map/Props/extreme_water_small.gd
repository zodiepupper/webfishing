extends WaterMain

export var depth = - 0.006
export var sand = true
export var kills = true

func _ready():
	$sand.translation.y = depth
	$sand.visible = sand
	$Area.monitorable = kills
