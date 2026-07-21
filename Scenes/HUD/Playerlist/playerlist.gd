extends Control

onready var entry = preload("res://Scenes/HUD/Playerlist/player_entry.tscn")
onready var server_name = $server_name
onready var player_count = $player_count
onready var invite = $invite_button

onready var playerlist = $panel / ScrollContainer / HBoxContainer / VboxContainer / playerlist
onready var no_playerlist = $panel / ScrollContainer / HBoxContainer / VboxContainer / no_player_label

onready var requestlist = $panel / ScrollContainer / HBoxContainer / VboxContainer / requestlist
onready var requestlabel = $panel / ScrollContainer / HBoxContainer / VboxContainer / request_label
onready var no_requestlist = $panel / ScrollContainer / HBoxContainer / VboxContainer / no_player_label2

onready var banlist = $panel / ScrollContainer / HBoxContainer / tab2 / banlist
onready var banlabel = $panel / ScrollContainer / HBoxContainer / tab2 / banlist_label
onready var bansep = $panel / ScrollContainer / HBoxContainer / tab2 / sep
onready var no_ban = $panel / ScrollContainer / HBoxContainer / tab2 / no_ban_label

onready var blocklist = $panel / ScrollContainer / HBoxContainer / tab2 / blocklist
onready var no_blocklist = $panel / ScrollContainer / HBoxContainer / tab2 / no_block_label

onready var tab_0 = $tab_plyrs
onready var tab_1 = $tab_band

onready var ban_count = $tab_band / ban_count
onready var ban_count_lbl = $tab_band / ban_count / ban_count_label

func _ready():
	Network.connect("_members_updated", self, "_refresh_list")
	Network.connect("_weblobby_request_update", self, "_refresh_list")
	Network.connect("_mute_update", self, "_refresh_list")
	PlayerData.connect("_mute_update", self, "_refresh_list")
	
	tab_0.connect("pressed", self, "_change_tab", [0])
	tab_1.connect("pressed", self, "_change_tab", [1])
	
	_change_tab(0)
	_refresh_list()

func _refresh_list():
	for child in playerlist.get_children(): child.queue_free()
	for player in Network.WEB_LOBBY_MEMBERS:
		var player_data = {"steam_name": Steam.getFriendPersonaName(player), "steam_id": player}
		var e = entry.instance()
		playerlist.add_child(e)
		e._setup(player_data, 0)
	no_playerlist.visible = Network.WEB_LOBBY_MEMBERS.size() <= 0
	
	for child in requestlist.get_children(): child.queue_free()
	for player in Network.WEB_LOBBY_JOIN_QUEUE:
		var player_data = {"steam_name": Steam.getFriendPersonaName(player), "steam_id": player}
		var e = entry.instance()
		requestlist.add_child(e)
		e._setup(player_data, 1)
	requestlist.visible = not Network.WEB_LOBBY_AUTO_ACCEPT and Network.GAME_MASTER
	requestlabel.visible = not Network.WEB_LOBBY_AUTO_ACCEPT and Network.GAME_MASTER
	no_requestlist.visible = not Network.WEB_LOBBY_AUTO_ACCEPT and Network.GAME_MASTER and Network.WEB_LOBBY_JOIN_QUEUE.size() <= 0
	
	for child in banlist.get_children(): child.queue_free()
	for player in Network.WEB_LOBBY_REJECTS:
		var player_data = {"steam_name": Steam.getFriendPersonaName(player), "steam_id": player}
		var e = entry.instance()
		banlist.add_child(e)
		e._setup(player_data, 2)
	banlist.visible = Network.GAME_MASTER
	banlabel.visible = Network.GAME_MASTER
	bansep.visible = Network.GAME_MASTER
	no_ban.visible = Network.GAME_MASTER and Network.WEB_LOBBY_REJECTS.size() <= 0
	
	for child in blocklist.get_children(): child.queue_free()
	for player in PlayerData.players_hidden:
		var player_data = {"steam_name": Steam.getFriendPersonaName(player), "steam_id": player}
		var e = entry.instance()
		blocklist.add_child(e)
		e._setup(player_data, 3)
	no_blocklist.visible = PlayerData.players_hidden.size() <= 0
	
	var text = ""
	if not Network.PLAYING_OFFLINE:
		var display = Steam.getLobbyData(Network.STEAM_LOBBY_ID, "name")
		var display_custom = Steam.getLobbyData(Network.STEAM_LOBBY_ID, "lobby_name")
		
		if display_custom != "": text = text + " " + str(display_custom)
		else: text = text + "" + str(display) + "'s Lobby"
		
		text = text
		invite.disabled = false
	else:
		text = "Solo World"
		invite.disabled = true
	
	server_name.text = text
	player_count.text = str(Network.WEB_LOBBY_MEMBERS.size()) + " / " + str(Steam.getLobbyData(Network.STEAM_LOBBY_ID, "cap")) + " Player(s)"
	
	ban_count.visible = (Network.WEB_LOBBY_REJECTS.size() + PlayerData.players_hidden.size()) > 0
	ban_count_lbl.text = str(Network.WEB_LOBBY_REJECTS.size() + PlayerData.players_hidden.size())

func _on_invite_button_pressed():
	Steam.activateGameOverlayInviteDialog(Network.STEAM_LOBBY_ID)

func _change_tab(to):
	$panel / ScrollContainer / HBoxContainer / VboxContainer.visible = to == 0
	$panel / ScrollContainer / HBoxContainer / tab2.visible = to == 1
	
	$tab_plyrs.disabled = to == 0
	$tab_band.disabled = to == 1
