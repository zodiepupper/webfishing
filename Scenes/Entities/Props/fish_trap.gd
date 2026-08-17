extends Interactable

var has_fish = false
var fish_data = []

var blink_cd = 0
var failed_chances = 0.0
var progress = 0

@export var fish_type = "lake"

func _ready():
	$caught.visible = false
	
func _activate(actor):
	if not get_parent().controlled:
		PlayerData._send_notification("This buddy isnt yours!", 1)
		return
	
	if not has_fish:
		PlayerData._send_notification("This buddy is empty!", 1)
		return
	else:
		has_fish = false
		$caught.visible = false
		
		var ref = _send_item()
		
		actor._obtain_item(ref, [])
		fish_data.clear()
		
		PlayerData._catch_fish()

func _on_Timer_timeout():
	$owned.visible = get_parent().controlled
	
	if not get_parent().controlled or has_fish: return
	
	var main = 0.012 + failed_chances
	if randf() > main:
		failed_chances += 0.004
		return
	failed_chances = 0.0
	
	progress += 1
	$AnimationPlayer.play("bounce")
	$sound.get_child(randi() % 3).play()
	
	var _max = [12, 10, 8, 7, 6, 5, 5][PlayerData.buddy_speed]
	
	if progress < _max: return
	progress = 0
	
	$catch_ring.play()
	
	var roll = Globals._roll_loot_table(fish_type, 2)
	var size = Globals._roll_item_size(roll)
	var quality = 0
	var max_quality = PlayerData.buddy_level
	
	var quality_chances = {
		0: [1.0], 
		1: [1.0, 0.05], 
		2: [1.0, 0.15, 0.05], 
		3: [1.0, 0.5, 0.25, 0.05], 
		4: [1.0, 0.8, 0.45, 0.15, 0.05], 
		5: [1.0, 0.98, 0.75, 0.55, 0.25, 0.05], 
	}
	
	for i in max_quality:
		var chance = quality_chances[max_quality][i + 1]
		if randf() < chance:
			quality += 1
	
	fish_data = [roll, size, quality]
	has_fish = true
	
	$caught.visible = true
	PlayerData._send_notification("one of your buddies caught something!")

func _physics_process(delta):
	blink_cd -= 1
	$idle_fish / main / eyes.visible = blink_cd > 0
	if blink_cd <= - 15: blink_cd = randf_range(60, 400)
	
	$idle_fish / main.scale.y = 0.995 + sin(Time.get_ticks_msec() * 0.001) * 0.005
	$caught.position.y = 2.1 + sin(Time.get_ticks_msec() * 0.002) * 0.1

func _send_item():
	var fish_roll = fish_data[0]
	var size = fish_data[1]
	var quality = fish_data[2]
	var data = Globals.item_data[fish_roll]["file"]
	
	var ref = PlayerData._add_item(fish_roll, - 1, size, quality, [])
	PlayerData._log_item(fish_roll, size, quality)
	PlayerData._quest_progress("catch", fish_roll)
	PlayerData._quest_progress("catch_type", data.loot_table)
	PlayerData._quest_progress("catch_small", PlayerData._get_size_type(fish_roll, size))
	PlayerData._quest_progress("catch_big", PlayerData._get_size_type(fish_roll, size))
	if data.tier == 2: PlayerData._quest_progress("catch_hightier")
	
	return ref

func _on_fish_trap__clearing():
	if not get_parent().controlled or not has_fish: return
	
	_send_item()
	PlayerData._send_notification("your buddy sent his fish to you!")
	fish_data.clear()
