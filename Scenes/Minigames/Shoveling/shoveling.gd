extends Minigame

var health = 10
var active = false

func _ready():
	active = true
	health = ceil(rand_range(6, 12))
	$main / Panel / TextureProgress.max_value = health

func _physics_process(delta):
	if Input.is_action_just_pressed("primary_action") and active:
		health -= 1
	
	if health <= 0:
		active = false
		_reached_end()
	
	$main / Panel / TextureProgress.value = health

func _reached_end():
	
	_end(true)
