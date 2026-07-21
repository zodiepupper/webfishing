extends Actor

var fish_data = {}
var wander_x = 9.5
var wander_y = 1.5
var flip = false

var anchor = Vector3()
var destination = Vector3()
var speed = 3.0
var cooldown = 10
var alive = true
var offs = 0
var mult = 1.0

func _ready():
	custom_valid_actions = ["_change_id"]
	_change_id(fish_data)

func _physics_process(delta):
	$Sprite3D.flip_h = flip

func _setup_controlled():
	randomize()
	offs = randi() % 2000
	anchor = global_transform.origin
	global_transform.origin = anchor + Vector3(
			rand_range( - wander_x, wander_x), 
			rand_range( - wander_y, wander_y), 
			rand_range( - wander_x, wander_x))
	PlayerData.connect("_aquarium_update", self, "_host_change_id")
	Network.connect("_new_player_join", self, "_host_change_id")

func _host_change_id():
	if not controlled: return
	Network._send_actor_action(actor_id, "_change_id", [PlayerData.saved_aqua_fish])
	_change_id(PlayerData.saved_aqua_fish)

func _change_id(new):
	if new == {} or new.empty():
		new["id"] = "empty"
		new["quality"] = 0
	
	var id = new.id
	var item_sprite = $Sprite3D
	
	if id == "empty":
		item_sprite.texture = null
	else:
		var item_data = Globals.item_data[id]["file"]
		item_sprite.texture = item_data.icon.duplicate()
		
		var scale_mult = 0.07 - clamp(new["size"] * 0.01, 0.01, 0.061)
		var item_scale = 1.0 if not item_data.uses_size else new["size"] * scale_mult
		item_sprite.scale = Vector3(item_scale, item_scale, item_scale)
		
		alive = item_data.alive
	
	for child in item_sprite.get_children(): child.emitting = false
	
	if PlayerData.QUALITY_DATA.has(new["quality"]):
		item_sprite.modulate = Color(PlayerData.QUALITY_DATA[new["quality"]]["mod"])
		item_sprite.opacity = PlayerData.QUALITY_DATA[new["quality"]]["op"]
		if PlayerData.QUALITY_DATA[new["quality"]]["particle"] > - 1: item_sprite.get_child(PlayerData.QUALITY_DATA[new["quality"]]["particle"]).emitting = true
	
	var rng = RandomNumberGenerator.new()
	rng.seed = new.ref if id != "empty" else 0
	rng.state = 0
	speed = rng.randf_range(0.3, 1.2)

func _controlled_process(delta):
	_process_movement(delta)
	custom_data["flip"] = flip

func _process_movement(delta):
	cooldown -= 1
	if cooldown <= 0:
		cooldown = randi() % 700 + 30
		destination = anchor + Vector3(
			rand_range( - wander_x, wander_x), 
			rand_range( - wander_y, wander_y), 
			rand_range( - wander_x, wander_x))
		flip = randf() < 0.5
		offs = randi() % 2000
	
	if alive:
		var t = OS.get_ticks_msec() + offs
		var t2 = OS.get_ticks_msec() + offs + 1000
		
		mult = lerp(mult, global_transform.origin.distance_to(destination) * 0.2, 0.7)
		global_transform.origin = global_transform.origin.move_toward(destination, delta * speed * mult)
		global_transform.origin.y += sin(t * 0.001) * 0.004
		global_transform.origin.x += sin(t2 * 0.001) * 0.004
		global_transform.origin.z += sin(t * 0.001) * 0.004
	else:
		global_transform.origin = global_transform.origin.move_toward(Vector3(global_transform.origin.x, anchor.y - wander_y, global_transform.origin.z), delta * 0.2)
	
