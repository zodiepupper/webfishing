extends Control

export (NodePath) var hud_node

var entered_fight = false
var entered_fight_began = false
var fight_active = false
var selected_fish = {}
var bet_amount = 0
var sent_fish = - 1

onready var hud = get_node(hud_node)

func _ready():
	PlayerData.connect("_arena_start", self, "_arena_start")
	PlayerData.connect("_arena_over", self, "_arena_over")
	PlayerData.connect("_arena_cashout", self, "_arena_cashout")

func _open():
	visible = true
	_refresh_fish()
func _close(): visible = false

func _on_Button_pressed():
	hud._request_item_choice([], 1, 1, "arena")
	var items = yield(hud, "_items_chosen")
	print("chosen items: ", items)
	
	for item in items:
		PlayerData.arena_fish.append(PlayerData._find_item_code(item))
		PlayerData._remove_item(item)
	
	_refresh_fish()

func _refresh_fish():
	var box = $Panel / Panel / ScrollContainer / VBoxContainer
	for child in box.get_children(): child.queue_free()
	
	for fish in PlayerData.arena_fish:
		var button = Button.new()
		button.text = str(fish)
		button.connect("pressed", self, "_select_fish", [fish])
		box.add_child(button)

func _select_fish(data):
	selected_fish = data

func _on_Button2_pressed():
	if selected_fish.empty():
		PlayerData._send_notification("select a fish first!", 1)
		return
	if entered_fight_began:
		PlayerData._send_notification("fight is currently active!", 1)
		return
	if entered_fight:
		PlayerData._send_notification("already entered!", 1)
		return
	
	entered_fight = true
	sent_fish = selected_fish.ref
	
	PlayerData._send_notification("entered next Fish Fighting match!")
	PlayerData.emit_signal("_arena_join", selected_fish.duplicate())
	Network._send_P2P_Packet({"type": "arena_join", "data": selected_fish.duplicate()}, "peers", 2)

func _bet():
	if not entered_fight:
		PlayerData._send_notification("need to enter before you can bet!", 1)
		return
	if entered_fight_began:
		PlayerData._send_notification("fight is currently active", 1)
		return
	if bet_amount >= 1000:
		PlayerData._send_notification("bet limit reached", 1)
		return
	bet_amount += 100
	PlayerData.money -= 100
	PlayerData._send_notification("-$100, cashout is now: " + str(ceil(bet_amount * 2)))

func _arena_start():
	fight_active = true
	if entered_fight:
		entered_fight_began = true
		PlayerData._send_notification("your Fish Fighting match has begun!")

func _arena_over():
	fight_active = false
	if entered_fight and entered_fight_began:
		entered_fight_began = false
		entered_fight = false

func _arena_cashout(data):
	if sent_fish == data[0]:
		PlayerData._send_notification("your fish got place " + str(data[1] + 1) + "!")
		if data[1] < 6:
			PlayerData.money += bet_amount * 2
			PlayerData._send_notification("payout of " + str(bet_amount * 2) + "!")
		
		if entered_fight_began:
			entered_fight_began = false
			entered_fight = false
			sent_fish = - 1
			bet_amount = 0
			PlayerData._send_notification("your Fish Fighting match is over!")
