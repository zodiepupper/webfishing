extends Panel

export (Texture) var texture
export var desc = ""
export var header = ""

var set_tier = 0

func _ready():
	$TextureRect.texture = texture
	$TooltipNode.body = desc
	$TooltipNode.header = header

func _setup(tier, time):
	set_tier = tier
	visible = tier > 0
	
	$TooltipNode.body = desc + "\n" + str(floor(time / 3600.0)) + " min"

func _physics_process(delta):
	if set_tier == 1: modulate.a = (sin(OS.get_ticks_msec() * 0.003) * 0.35) + 0.5
	else: modulate.a = 1.0
