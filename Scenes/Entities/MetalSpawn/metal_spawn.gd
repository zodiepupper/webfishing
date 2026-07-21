extends Actor

var found = false

func _ready():
	$Icosphere2.visible = false
	$Interactable.monitorable = false

func _reveal():
	if found: return
	found = true
	
	$Icosphere2.scale = Vector3(0.1, 0.1, 0.1)
	$Icosphere2.visible = true
	$Interactable.monitorable = true
	$lvl_particles.restart()
	$Particles.restart()

func _physics_process(delta):
	if found: $Icosphere2.scale = lerp($Icosphere2.scale, Vector3(1.0, 1.0, 1.0), 0.4)
