extends Minigame

onready var tilemap = $Node2D / TileMap
onready var root = $Node2D

var brush_size = 3
var step_size = 3
var last_pos = Vector2.INF

var grid_size = Vector2(5, 5)
var winning_numbers = []
var total_scratched = 0
var done = false
var won = false
var scratching = 0

func _ready():
	$Node2D / Sprite.frame = params["type"]
	
	GlobalAudio._play_sound("ui_open")
	print("CREATING LOTTO TICKET")
	$Control.visible = false

	randomize()

	tilemap.clear()
	for x in 64:
		for y in 56:
			var tile = 0
			tilemap.set_cell(x - 32, y - 12, tile)

	var blacklist = []
	for child in $Node2D / winning.get_children():
		var num = randi() % 50
		while blacklist.has(num):
			num = randi() % 50

		winning_numbers.append(num)
		child._set_number(num)
		blacklist.append(num)
		child._setup(params["type"])
	
	blacklist = []
	for child in $Node2D / spots.get_children():
		var num = randi() % 50
		while blacklist.has(num) or (winning_numbers.has(num) and randf() < 0.8):
			num = randi() % 50
	
		child._set_number(num)
		blacklist.append(num)
		child._setup(params["type"])
	
	for scratch in get_tree().get_nodes_in_group("scratch_spot"):
		scratch.connect("_scratched", self, "_slot_scratched")
	
	$AnimationPlayer.play("intro")

func _physics_process(delta):
	if Input.is_action_pressed("primary_action"):
		if last_pos == Vector2.INF: return
		var pos = tilemap.world_to_map(root.get_global_mouse_position() - tilemap.global_position)
		_scratch(pos, last_pos)
		last_pos = pos
	else:
		var pos = tilemap.world_to_map(root.get_global_mouse_position() - tilemap.global_position)
		last_pos = pos
	
	if scratching > 0: scratching -= 1
	$scratching.volume_db = lerp($scratching.volume_db, linear2db(0.2 if scratching > 0 else 0.01), 0.2)
	if not $scratching.playing and $scratching.volume_db > - 30: $scratching.playing = true
	if $scratching.playing and $scratching.volume_db < - 30: $scratching.playing = false

func _scratch(grid_pos, from):
	var steps = 1 + floor(from.distance_to(grid_pos) / step_size)
	for s in steps:
		var step = (s * step_size) * (from - grid_pos).normalized()
		var pos = grid_pos + step

		for x in brush_size:
			for y in brush_size:
				var final = Vector2(pos.x + x, pos.y + y)
				if tilemap.get_cell(final.x, final.y) != - 1: scratching = 5
				tilemap.set_cell(final.x, final.y, - 1)

func _slot_scratched():
	if done: return

	total_scratched += 1
	if get_tree().get_nodes_in_group("scratch_spot").size() <= total_scratched:
		done = true
		
		won = false
		for scratch in get_tree().get_nodes_in_group("scratch_spot"):
			if not scratch.winning and winning_numbers.has(scratch.saved_num):
				PlayerData._send_notification("You won $" + str(scratch.prize_amt) + " from the scratch off!")
				PlayerData.money += scratch.prize_amt
				won = true
				scratch._win_ping()
				GlobalAudio._play_sound("short_win")
				yield(get_tree().create_timer(0.4), "timeout")
		
		if not won:
			PlayerData._send_notification("You didnt win anything! Better luck next time...", 1)
			GlobalAudio._play_sound("jingle_lose")
		else:
			GlobalAudio._play_sound("jingle_win")
		
		$Control.visible = true

func _on_Button_pressed():
	_end(won)
