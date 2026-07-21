extends CanvasLayer

var shake = 0.0
var lowered = false
var xp_to_add = 0
var xp_amt = 0
var xp_goal = 0
var wait_cd = 0
var level = 0

onready var label_1 = $Control / Panel / RichTextLabel
onready var label_2 = $Control / Panel / RichTextLabel2
onready var label_3 = $Control / Panel / RichTextLabel3
onready var label_4 = $Control / Panel / RichTextLabel4
onready var prog = $Control / Panel / ProgressBar_prog
onready var bar = $Control / Panel / ProgressBar_main

func _ready():
	PlayerData.connect("_xp_add", self, "_add_xp")
	
	$Control.margin_bottom = - 300
	$Control.margin_left = 0
	$Control.margin_right = 0
	$Control.margin_top = - 300
	$AnimationPlayer.play("RESET")

func _add_xp(amt, lvl, total):
	if not lowered:
		$AnimationPlayer.stop()
		$AnimationPlayer.play("anim")
		xp_amt = total
		_set_level(lvl)
		bar.value = xp_amt
		wait_cd = 40
	
	lowered = true
	xp_to_add += amt

func _physics_process(delta):
	$Control / Panel.rect_position.y = 21.6 + (sin(OS.get_ticks_msec() * 0.015) * shake)
	shake = lerp(shake, 0.0, 0.1)
	
	if wait_cd > 0:
		wait_cd -= 1
	elif xp_to_add > 0:
		var amt = 1
		if xp_to_add > 100:
			amt = 3
		if xp_to_add > 100:
			amt = 8
		
		xp_to_add -= amt
		xp_amt += amt
		prog.value = xp_amt
		if xp_to_add <= 0: wait_cd = 40
	elif lowered:
		lowered = false
		$AnimationPlayer.play_backwards("anim")
	
	label_3.bbcode_text = "+" + str(xp_to_add)
	label_4.bbcode_text = "[center]" + str(xp_amt) + "/" + str(xp_goal)
	
	if xp_amt >= xp_goal:
		_set_level(level + 1)
		xp_amt = 0
		prog.value = 0
		bar.value = 0
		shake = 25

func _set_level(lvl):
	if PlayerData.BADGE_LEVEL_DATA.size() < lvl: lvl = PlayerData.BADGE_LEVEL_DATA.size()
	
	var data = PlayerData._get_level_data(lvl)
	
	level = lvl
	xp_goal = PlayerData._get_xp_goal(level)
	bar.max_value = xp_goal
	prog.max_value = xp_goal
	label_1.bbcode_text = str(data["title"])
	label_2.bbcode_text = "[right]RANK " + str(lvl)
	$Control / item_display.texture = data["icon"]
