extends Actor

var arena_origin = Vector3()
var spawn_range = 3.5

var direction = Vector3()
var velocity = Vector3()
var speed = 5.0

var max_health = 100
var health = 100
var damage = 10
var block_chance = 0.0
var regen = 0

var data = {}

var alive = true

func _ready():
	add_to_group("arena_fish")
	var i_data = Globals.item_data[data["id"]]["file"]
	$Sprite3D.texture = i_data.icon

func _setup_controlled():
	
	var effects = data.arena_effects
	for effect in effects:
		var effect_data = PlayerData.ARENA_EFFECTS[effect]
		
		match effect_data.op:
			"+": set(effect_data. var , get(effect_data. var ) + effect_data.val)
	
	health = max_health
	
	
	arena_origin = global_transform.origin
	global_transform.origin += Vector3(
					rand_range( - spawn_range, spawn_range), 
					0.3, 
					rand_range( - spawn_range, spawn_range))
	direction = Vector3(rand_range( - 1, 1), 0.0, rand_range( - 1, 1))

func _controlled_process(delta):
	if get_slide_count() > 0:
		for s in get_slide_count():
			var c = get_slide_collision(s).collider
			if c == null: continue
			if c.is_in_group("arena_fish") and c != self:
				c._hurt(ceil(damage * rand_range(0.8, 1.2)))
		
		var n = get_slide_collision(0).normal
		direction = direction.bounce(n)
		direction.y = 0
	
	velocity = direction.normalized() * speed
	move_and_slide(velocity)

func _hurt(amt):
	if not controlled: return
	
	if amt < 400 and randf() < block_chance: amt = 0
	
	health -= amt
	if health <= 0:
		alive = false
		PlayerData.emit_signal("_arena_death", data.ref)
		_deinstantiate(true)

func _on_Timer_timeout():
	if not controlled: return
	health += regen
