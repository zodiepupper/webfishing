extends Actor

var lifetime = 2000

func _controlled_process(delta):
	lifetime -= 3
	custom_data["lifetime"] = lifetime
	
	if lifetime <= 0:
		_deinstantiate(true)

func _physics_process(delta):
	$MeshInstance.visible = lifetime > 1500
	$MeshInstance2.visible = lifetime > 500 and lifetime <= 1500
	$MeshInstance3.visible = lifetime <= 500
