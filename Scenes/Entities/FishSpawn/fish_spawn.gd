extends Actor

var tier = 0

func _ready():
	$pivot / AnimationPlayer.play("intro")
	$Area.id = actor_id
	$pivot / body.get_child(tier).show()

func _physics_process(delta):
	$pivot.rotation_degrees.y += delta * PI * 16.0

func _on_Timer_timeout():
	visible = false
	$Area / CollisionShape.disabled = true
