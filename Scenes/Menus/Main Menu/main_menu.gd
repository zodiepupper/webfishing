extends Control

enum LOBBY_SORT{PLAYER_HIGH, PLAYER_LOW, RANDOM}

var hovered_button = null
var disabled = false
var refreshing = false
var lobby_search_time = 0
var server_age_limit = false

var lobby_search_sort = LOBBY_SORT.PLAYER_HIGH
var lobby_filters_shown = false
var lobby_names_shown = true

onready var code = $lobby_browser / Panel / code_join / HBoxContainer / serv_options
onready var dial = $lobby_browser / Panel / lobbies / TextureRect / Control / dial
onready var playercount_dial = $lobby_browser / Panel / filters / ScrollContainer / HBoxContainer / VBoxContainer / playercount_filters / dial

signal _name_toggle(toggle)
signal _button_disable

func _ready():
	Network.set_rich_presence("#menu")
	Network.connect("_webfishing_lobbies_returned", self, "_lobby_list_returned")
	Network.connect("_menu_button_disable", self, "_disable_buttons")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	$HBoxContainer / Label.text = "lamedeveloper v" + str(Globals.GAME_VERSION)
	
	for child in $VBoxContainer.get_children():
		if child is Button:
			child.connect("mouse_entered", self, "_hover_button", [child])
			child.connect("mouse_exited", self, "_exit_button", [child])
			child.add_to_group("menu_button")
	
	for lobby_type in Network.LOBBY_TYPE_DATA.keys():
		var data = Network.LOBBY_TYPE_DATA[lobby_type]
		$"%serv_options".add_item(data.name)
	
	for i in 12: $"%max_players".add_item(str(i + 1))
	$"%max_players".selected = 11
	
	$"%players_request2".add_item("Automatic")
	$"%players_request2".add_item("Manual")
	
	$"%lobbyname".placeholder_text = str(Network.STEAM_USERNAME) + "'s Lobby"
	
	_close_browser()
	_close_create_screen()
	_close_tag_menu()
	
	yield(get_tree().create_timer(1.0), "timeout")
	Network._lobby_join_prompted(Network.JOIN_ID_PROMPT)

func _process(delta):
	$TextureRect.margin_top = sin(OS.get_ticks_msec() * 0.001) * 8
	$TextureRect.margin_bottom = sin(OS.get_ticks_msec() * 0.001) * 8
	
	
	
	
	
	for node in get_tree().get_nodes_in_group("menu_button"):
		node.size_flags_stretch_ratio = lerp(node.size_flags_stretch_ratio, 0.5 if hovered_button != node else 1.0, 0.1)

func _physics_process(delta):
	dial.rotation_degrees += 6.0




func _on_quit_pressed(): Globals._close_game()
func _on_reset_pressed(): PlayerData._reset_save()

func _disable_buttons():
	disabled = true
	
	
	$create_lobby_menu / Panel / Panel / Button.disabled = true
	
	
	$lobby_browser / Panel / code_join / HBoxContainer / Button.disabled = true
	
	emit_signal("_button_disable")

func _hover_button(node):
	hovered_button = node
func _exit_button(node):
	hovered_button = null

func _on_settings_pressed():
	OptionsMenu._open()





func _open_create_screen():
	$create_lobby_menu.visible = true
	_close_tag_menu()
func _close_create_screen():
	$create_lobby_menu.visible = false
	_close_tag_menu()


func _open_tag_menu():
	$create_lobby_tag_menu.visible = true
func _close_tag_menu():
	var tags_selected = 0
	for tag in get_tree().get_nodes_in_group("tags"):
		if tag.pressed: tags_selected += 1
	
	$create_lobby_menu / Panel / Panel / VBoxContainer / social_tags / Button.text = str(tags_selected) + " Tag(s) Selected"
	$create_lobby_tag_menu.visible = false





func _open_browser():
	$lobby_browser.visible = true
	_refresh_lobbies()
func _close_browser(): $lobby_browser.visible = false

func _refresh_lobbies():
	var lob = $lobby_browser / Panel / lobbies / ScrollContainer / VBoxContainer
	for child in lob.get_children(): child.queue_free()
	
	yield(get_tree().create_timer(0.2), "timeout")
	print("Requesting a lobby list")
	
	dial.show()
	refreshing = true
	lobby_search_time = 0
	
	var tags_to_filter = []
	for child in $"%tag_filter_search".get_children():
		if child.pressed: tags_to_filter.append(child.lobby_tag)
	
	var must_match = $"%must_match".pressed
	
	Network._find_all_webfishing_lobbies(tags_to_filter, must_match)

func _lobby_list_returned(lobbies):
	if not refreshing: return
	
	var lob = $lobby_browser / Panel / lobbies / ScrollContainer / VBoxContainer
	var valid_lobbies = 0
	
	var min_player_count = playercount_dial.min_set + 1
	var max_player_count = playercount_dial.max_set + 1
	if playercount_dial.max_set >= playercount_dial.dial_max:
		max_player_count = 99
	
	var validated_list = []
	var known_lobbies = []
	for lobby in lobbies:
		var lobby_num_members = Steam.getNumLobbyMembers(lobby)
		var browser_visible = Steam.getLobbyData(lobby, "public")
		var lobby_real_members = int(Steam.getLobbyData(lobby, "count"))
		var lobby_cap = int(Steam.getLobbyData(lobby, "cap"))
		
		
		
		if browser_visible != "true": continue
		if lobby_num_members < min_player_count or lobby_num_members > max_player_count: continue
		if $"%hide_full".pressed and lobby_real_members >= lobby_cap: continue
		if known_lobbies.has(lobby): continue
		known_lobbies.append(lobby)
		
		validated_list.append([lobby, lobby_num_members])
	
	var sorted_list = validated_list.duplicate()
	
	match lobby_search_sort:
		LOBBY_SORT.PLAYER_HIGH: sorted_list.sort_custom(self, "_lobby_sort_high")
		LOBBY_SORT.PLAYER_LOW: sorted_list.sort_custom(self, "_lobby_sort_low")
		LOBBY_SORT.RANDOM: sorted_list.sort_custom(self, "_lobby_sort_random")
	
	for entry in sorted_list:
		var lobby = entry[0]
		
		var lobby_name = Steam.getLobbyData(lobby, "name")
		var lobby_custom_name = Steam.getLobbyData(lobby, "lobby_name")
		var lobby_num_members = Steam.getLobbyData(lobby, "count")
		var lobby_num_members_total = Steam.getNumLobbyMembers(lobby)
		var lobby_cap = Steam.getLobbyData(lobby, "cap")
		var lobb_version = Steam.getLobbyData(lobby, "version")
		var lobb_request = Steam.getLobbyData(lobby, "request") == "true"
		
		var dated = str(lobb_version) != str(Globals.GAME_VERSION)
		var lobby_tags = []
		for tag in Network.LOBBY_TAGS:
			if int(Steam.getLobbyData(lobby, "tag_" + tag)) == 1: lobby_tags.append(tag)
		
		valid_lobbies += 1
		
		
		if int(lobby_cap) > 12: lobby_tags.append("modded")
		
		var lb = preload("res://Scenes/Menus/Main Menu/ServerButton/server_button.tscn").instance()
		lb.label_toggle = lobby_names_shown
		lb._setup(lobby_name, lobby_custom_name, lobby_num_members, lobby_num_members_total, lobby_cap, lobby_tags, dated, lobb_request)
		lob.add_child(lb)
		lb.connect("_pressed", self, "_join_lobby", [lobby])
		connect("_button_disable", lb, "_disable")
		
		connect("_name_toggle", lb, "_label_toggle")
	
	print(lobbies.size(), " found.")
	dial.hide()
	refreshing = false
	
	if valid_lobbies <= 0:
		var lbl = Label.new()
		lbl.text = "No Servers Found :("
		lob.add_child(lbl)

func _start_lobby():
	var tags = []
	for child in $"%tagbox".get_children():
		if child.pressed: tags.append(child.lobby_tag)
	
	var cap = $"%max_players".selected + 1
	var display_name = $"%lobbyname".text
	var request = $"%players_request2".selected == 0
	
	Network._create_custom_lobby($"%serv_options".selected, cap, tags, display_name, request)
	_disable_buttons()

func _join_lobby(id):
	if disabled: return
	
	var is_mature = int(Steam.getLobbyData(id, "mature")) == 1
	var is_modded = int(Steam.getLobbyData(id, "modded")) == 1
	
	if int(Steam.getLobbyData(id, "cap")) > 12: is_modded = true
	
	if is_mature:
		PopupMessage._show_popup("The lobby you're attempting to join has been marked as 'Mature'. By clicking 'Accept' you are aware this lobby's discussions could contain adult topics.", 0.0, true)
		var choice = yield(PopupMessage, "_choice_made")
		if not choice: return
	if is_modded:
		PopupMessage._show_popup("The lobby you're attempting to join has been marked as 'Modded'. By clicking 'Accept' you are aware this lobby's gameplay could not be accurate to a typical, intended gameplay experience.", 0.0, true)
		var choice = yield(PopupMessage, "_choice_made")
		if not choice: return
	
	Network._connect_to_lobby(id)
	_disable_buttons()

func _join_from_code():
	Network.PLAYING_OFFLINE = false
	Network._search_for_lobby(code.text)
	code.clear()
	_disable_buttons()

func _on_Timer_timeout():
	if refreshing:
		lobby_search_time += 1
		if lobby_search_time > 20:
			lobby_search_time = 0
			_lobby_list_returned([])

func _on_18_tag_pressed():
	server_age_limit = not server_age_limit
	$"%18_tag".text = "ENABLED" if server_age_limit else "DISABLED"

func _on_sort_list_pressed():
	lobby_search_sort += 1
	if lobby_search_sort > 2: lobby_search_sort = 0
	
	var search_button = $"%sort_list"
	match lobby_search_sort:
		LOBBY_SORT.PLAYER_HIGH: search_button.text = "Players: High to Low"
		LOBBY_SORT.PLAYER_LOW: search_button.text = "Players: Low to High"
		LOBBY_SORT.RANDOM: search_button.text = "Random"

func _lobby_sort_high(a, b): return a[1] > b[1]
func _lobby_sort_low(a, b): return a[1] < b[1]
func _lobby_sort_random(a, b): return randf() < 0.5


func _on_show_filters_pressed():
	lobby_filters_shown = not lobby_filters_shown
	
	$"%filters".visible = lobby_filters_shown
	$"%filter_dis".visible = not lobby_filters_shown
	$"%show_filters".text = "Show Filters" if not lobby_filters_shown else "Hide Filters"

func _on_show_names_toggled(button_pressed):
	lobby_names_shown = button_pressed
	emit_signal("_name_toggle", lobby_names_shown)


func _on_filter_mature_pressed():
	if not $"%filter_mature".pressed: return
	
	PopupMessage._show_popup("By enabling this you accept that lobbies shown may contain adult topics.", 0.0, true)
	var accepted = yield(PopupMessage, "_choice_made")
	if not accepted: $"%filter_mature".pressed = false

func _on_filter_modded_pressed():
	if not $"%filter_modded".pressed: return
	
	PopupMessage._show_popup("By enabling this you accept that lobbies shown may not work properly on your device.", 0.0, true)
	var accepted = yield(PopupMessage, "_choice_made")
	if not accepted: $"%filter_modded".pressed = false
