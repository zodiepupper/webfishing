extends Node

enum CHANNELS{
	ACTOR_UPDATE, 
	ACTOR_ACTION, 
	GAME_STATE, 
	CHALK, 
	GUITAR, 
	ACTOR_ANIMATION, 
	SPEECH, 
}
enum LOBBY_TYPES{
	PUBLIC, CODE_ONLY, FRIENDS_ONLY, PRIVATE, OFFLINE
}
var LOBBY_TYPE_DATA = {
	0: {"name": "Public", "lobby_type": Steam.LOBBY_TYPE_PUBLIC, "code_button": true, "browser_visible": true, "offline": false}, 
	1: {"name": "Unlisted", "lobby_type": Steam.LOBBY_TYPE_PUBLIC, "code_button": true, "browser_visible": false, "offline": false}, 
	2: {"name": "Private", "lobby_type": Steam.LOBBY_TYPE_PRIVATE, "code_button": false, "browser_visible": false, "offline": false}, 
	3: {"name": "Offline", "lobby_type": Steam.LOBBY_TYPE_PRIVATE, "code_button": true, "browser_visible": false, "offline": true}, 
}
enum DC_REASONS{USER_LEAVE, USER_KICK, USER_BAN}
enum DENY_REASONS{DENIED, LOBBY_FULL}

const KNOWN_DEVELOPERS = [76561198116925213]
const KNOWN_CONTRIBUTORS = [
	76561198075315616, 
	76561198109913387, 
	76561198108125836, 
	76561198298932199, 
	76561198048418963, 
	76561198057735456, 
	76561198816340850, 
	76561198087467489, 
	76561198826179386, 
	76561198215486940, 
	76561198353061650, 
	76561199104328044, 
	76561199179487223, 
	76561198169378907, 
	76561198407389557, 
]

const MAX_OWNED_ACTOR_LIMIT = 32
const MAX_PACKET_TIMEOUT_LIMIT = 1500
const MAX_MAJOR_PACKET_TIMEOUT_LIMIT = 3000
const PACKET_READ_LIMIT = 42
const TICKRATE = 16.0
const COMPRESSION_TYPE = FileAccess.COMPRESSION_GZIP
const LOBBY_TAGS = ["talkative", "quiet", "grinding", "chill", "silly", "hardcore", "mature", "modded"]


const VIRTUAL_PORT = 0
var NETWORK_SOCKET = - 1
var PLAYER_NICKNAME_PREFIX = ""

var STEAM_ENABLED = true
var PLAYING_OFFLINE = false
var IS_OWNED = false
var IS_ONLINE = false
var GAME_MASTER = false
var STEAM_ID = 0
var STEAM_USERNAME = ""
var PACK
var JOIN_ID_PROMPT = - 1

var STEAM_LOBBY_ID = 0
var LOBBY_CODE = ""
var OWNED_ACTORS = []
var ACTOR_ACTIONS = {}
var ACTOR_DATA = {}
var ACTOR_ANIMATION_DATA = {}
var SERVER_CREATION_TYPE = 0
var PING_DICTIONARY = {}
var LOBBY_CHUNK_SIZE = 50

var GAMECHAT = ""
var GAMECHAT_COLLECTIONS = []
var LOCAL_GAMECHAT = ""
var LOCAL_GAMECHAT_COLLECTIONS = []

var SERVER_SETUP_TAGS = []
var SERVER_SETUP_TITLE = ""
var SERVER_SETUP_CAP = 0
var CREATING_SERVER = false
var CODE_ENABLED = false

var BULK_PACKET_READ_TIMER = 0

var KNOWN_GAME_MASTER = - 1

var MESSAGE_ORIGIN = Vector3.ZERO
var MESSAGE_ZONE = ""


var LOBBY_MEMBERS = []
var WEB_LOBBY_MEMBERS = []
var WEB_LOBBY_REJECTS = []
var WEB_LOBBY_KNOWN_REQUESTS = []
var WEB_LOBBY_JOIN_QUEUE = []
var WEB_LOBBY_AUTO_ACCEPT = false
var WEB_LOBBY_MAX_USERS = 12
var IN_WEB_LOBBY = false
var WEB_LOBBY_HOST = false

var REPLICATIONS_RECIEVED = []
var OPEN_CONNECTIONS = []


var FLUSH_PACKET_INFORMATION = {}
var PACKET_TIMEOUTS = []
var MESSAGE_COUNT_TRACKER = {}

var NETWORK_TIMER
signal _network_tick

signal _connected_to_lobby
signal _actors_recieved
signal _user_disconnected(id)
signal _user_connected(id)
signal _all_user_data_obtained
signal _instance_actor
signal _members_updated
signal _tent_update
signal _chat_update
signal _new_player_join(id)
signal _new_player_join_empty
signal _webfishing_lobbies_returned(lobbies)
signal _menu_button_disable

signal _denied_into_weblobby_signal
signal _new_request_from_weblobby(id)
signal _weblobby_request_update

func _init():
	
	
	
	
	if not STEAM_ENABLED: return
	OS.set_environment("SteamAppId", str(3146520))
	OS.set_environment("SteamGameId", str(3146520))

func _ready():
	if not STEAM_ENABLED: return
	var INIT = Steam.steamInitEx()
	
	if INIT["status"] != 1:
		print("Failed to initialize Steam. Shutting down. %s" % INIT["status"])
		get_tree().quit()
	
	IS_OWNED = Steam.isSubscribed()
	IS_ONLINE = Steam.loggedOn()
	STEAM_ID = Steam.getSteamID()
	STEAM_USERNAME = Steam.getPersonaName()
	
	print("Steam Active under username: ", STEAM_USERNAME, " ID: ", STEAM_ID)
	
	if IS_OWNED == false:
		print("User does not own game.")
		get_tree().quit()
	
	Steam.connect("lobby_created", Callable(self, "_on_Lobby_Created"))
	Steam.connect("lobby_joined", Callable(self, "_on_Lobby_Joined"))
	Steam.connect("join_requested", Callable(self, "_on_Lobby_Join_Requested"))
	Steam.connect("p2p_session_request", Callable(self, "_on_P2P_Session_Request"))
	Steam.connect("lobby_chat_update", Callable(self, "_on_Lobby_Chat_Update"))
	Steam.connect("network_messages_session_request", Callable(self, "_session_request"))
	Steam.connect("lobby_message", Callable(self, "_steam_lobby_message"))
	
	Steam.initRelayNetworkAccess()
	_reset_network_socket()
	
	_check_command_line()
	
	NETWORK_TIMER = Timer.new()
	add_child(NETWORK_TIMER)
	NETWORK_TIMER.wait_time = 1.0 / TICKRATE
	NETWORK_TIMER.connect("timeout", Callable(self, "emit_signal").bind("_network_tick"))
	NETWORK_TIMER.start()
	
	var PACKET_FLUSH_TIMER = Timer.new()
	add_child(PACKET_FLUSH_TIMER)
	PACKET_FLUSH_TIMER.wait_time = 5.0
	PACKET_FLUSH_TIMER.connect("timeout", Callable(self, "_packet_flush"))
	PACKET_FLUSH_TIMER.start()
	
	var MESSAGE_COUNT_TIMER = Timer.new()
	add_child(MESSAGE_COUNT_TIMER)
	MESSAGE_COUNT_TIMER.wait_time = 1.5
	MESSAGE_COUNT_TIMER.connect("timeout", Callable(self, "_message_flush"))
	MESSAGE_COUNT_TIMER.start()


func _check_command_line():
	var these_arguments: Array = OS.get_cmdline_args()
	if these_arguments.size() > 0:
		if these_arguments[0] == "+connect_lobby":
			if int(these_arguments[1]) > 0:
				print("Command line lobby ID: %s" % these_arguments[1])
				JOIN_ID_PROMPT = int(these_arguments[1])


func _process(delta):
	if not STEAM_ENABLED: return
	Steam.run_callbacks()
	
	if STEAM_LOBBY_ID <= 0: return
	
	for channel in CHANNELS.size():
		_read_all_P2P_packets(channel)

func _read_all_P2P_packets(channel = 0):
	for i in 32:
		var message_count = Steam.receiveMessagesOnChannel(channel, 8)
		if message_count.size() <= 0: break
		for message in message_count:
			_read_P2P_Packet(message)

func _update_chat(text, local = false):
	var max_message_length = 512
	var max_chat_length = 128
	
	text = text.left(max_message_length)
	
	var final_text = ""
	
	if not local:
		text = "\n" + text
		GAMECHAT_COLLECTIONS.append(text)
		if GAMECHAT_COLLECTIONS.size() > max_chat_length:
			GAMECHAT_COLLECTIONS.remove(0)
		
		GAMECHAT = ""
		for msg in GAMECHAT_COLLECTIONS:
			GAMECHAT = GAMECHAT + msg
		
	else:
		text = "\n" + "[color=#a4756a][​local​] [/color]" + text
		LOCAL_GAMECHAT_COLLECTIONS.append(text)
		if LOCAL_GAMECHAT_COLLECTIONS.size() > max_chat_length:
			LOCAL_GAMECHAT_COLLECTIONS.remove(0)
		
		LOCAL_GAMECHAT = ""
		for msg in LOCAL_GAMECHAT_COLLECTIONS:
			LOCAL_GAMECHAT = LOCAL_GAMECHAT + msg
	
	emit_signal("_chat_update")

func _recieve_safe_message(user_id, color, message, local = false):
	
	var username = _get_username_from_id(user_id)
	username = username.replace("[", "")
	username = username.replace("]", "")
	
	
	var filter_message = message
	filter_message = filter_message.replace("[", "")
	filter_message = filter_message.replace("]", "")
	
	if OptionsMenu.chat_filter:
		filter_message = SwearFilter._filter_string(filter_message)
	
	var filter_color = str(Color(str(color)).to_html())
	filter_color = filter_color.replace("[", "")
	filter_color = filter_color.replace("]", "")
	
	var final_message = filter_message.replace("%u", "[color=#" + filter_color + "]" + username + "[/color]")
	_update_chat(final_message, local)





func _unlock_achievement(id):
	var achievement = Steam.getAchievement(id)
	if not achievement.ret:
		print("Achievement ", id, " does not exist.")
		return
	if achievement.achieved:
		print("Achievement ", id, " already obtained.")
		return
	Steam.setAchievement(id)
	Steam.storeStats()

func _update_stat(id, new):
	Steam.setStatInt(id, int(new))
	Steam.storeStats()





func set_rich_presence(token):
	
	var setting_presence = Steam.setRichPresence("steam_display", token)










func _reset_lobby_status():
	print("Resetting Lobby Status...")
	STEAM_LOBBY_ID = 0
	GAME_MASTER = false
	REPLICATIONS_RECIEVED.clear()
	LOBBY_MEMBERS.clear()
	OWNED_ACTORS.clear()
	FLUSH_PACKET_INFORMATION.clear()
	PACKET_TIMEOUTS.clear()
	MESSAGE_COUNT_TRACKER = {}
	GAME_MASTER = false
	CREATING_SERVER = false
	
	_wipe_chat()

func _wipe_chat():
	GAMECHAT = ""
	GAMECHAT_COLLECTIONS.clear()
	LOCAL_GAMECHAT = ""
	LOCAL_GAMECHAT_COLLECTIONS.clear()


func _reset_network_socket():
	print("Network Socket Reset")
	Steam.closeListenSocket(NETWORK_SOCKET)
	NETWORK_SOCKET = Steam.createListenSocketP2P(VIRTUAL_PORT, {})





func _setup_new_weblobby():
	_clear_weblobby()
	WEB_LOBBY_MEMBERS.append(STEAM_ID)
	IN_WEB_LOBBY = true
	WEB_LOBBY_HOST = true

func _clear_weblobby():
	WEB_LOBBY_MEMBERS.clear()
	WEB_LOBBY_REJECTS.clear()
	WEB_LOBBY_JOIN_QUEUE.clear()
	IN_WEB_LOBBY = false
	WEB_LOBBY_HOST = false




func _user_weblobby_join_request(steam_id):
	if not GAME_MASTER or PLAYING_OFFLINE: return
	
	if WEB_LOBBY_JOIN_QUEUE.has(steam_id) or WEB_LOBBY_MEMBERS.has(steam_id): return
	
	print("Weblobby Join Request From: ", steam_id)
	
	var valid_join = true
	var ban = true
	var reason = DENY_REASONS.DENIED
	
	if WEB_LOBBY_REJECTS.has(steam_id):
		valid_join = false
	if WEB_LOBBY_MEMBERS.size() >= WEB_LOBBY_MAX_USERS:
		valid_join = false
		reason = DENY_REASONS.LOBBY_FULL
		ban = false
	if WEB_LOBBY_JOIN_QUEUE.size() >= 99:
		valid_join = false
		reason = DENY_REASONS.LOBBY_FULL
		ban = false
	
	if valid_join:
		if WEB_LOBBY_AUTO_ACCEPT: _accept_user_into_weblobby(steam_id, false)
		else:
			if not WEB_LOBBY_KNOWN_REQUESTS.has(steam_id):
				WEB_LOBBY_KNOWN_REQUESTS.append(steam_id)
				emit_signal("_new_request_from_weblobby", steam_id)
				GlobalAudio._play_sound("request_jingle")
			
			WEB_LOBBY_JOIN_QUEUE.append(steam_id)
			emit_signal("_weblobby_request_update")
	else:
		_deny_user_into_weblobby(steam_id, reason, false, ban)


func _ask_to_join_weblobby():
	if STEAM_LOBBY_ID <= 0: return
	Steam.sendLobbyChatMsg(STEAM_LOBBY_ID, "$weblobby_join_request")


func _steam_lobby_message(lobby_id, user_id, message, chat_type):
	if lobby_id != STEAM_LOBBY_ID or user_id == STEAM_ID: return
	print("Lobby Message Recieved from ", user_id, ": ", message)
	
	var is_host = user_id == Steam.getLobbyOwner(STEAM_LOBBY_ID)
	var filtered_message = message.split("-")[0]
	
	var filter_id = - 1
	if message.split("-").size() > 1: filter_id = int(message.split("-")[1])
	
	
	if is_host:
		match filtered_message:
			"$weblobby_request_accepted": if filter_id == STEAM_ID: _accepted_into_weblobby()
			"$weblobby_request_denied_deny": if filter_id == STEAM_ID: _denied_into_weblobby(DENY_REASONS.DENIED)
			"$weblobby_request_denied_full": if filter_id == STEAM_ID: _denied_into_weblobby(DENY_REASONS.LOBBY_FULL)
	
	
	elif STEAM_ID == Steam.getLobbyOwner(STEAM_LOBBY_ID):
		match filtered_message:
			"$weblobby_join_request": _user_weblobby_join_request(user_id)


func _accept_user_into_weblobby(steam_id, send_notif = true):
	print("Weblobby Join Request Accepted for user: ", steam_id)
	WEB_LOBBY_JOIN_QUEUE.erase(steam_id)
	
	_user_joined_weblobby(steam_id)
	_send_P2P_Packet({"type": "user_joined_weblobby", "user_id": steam_id}, "all", 2, CHANNELS.GAME_STATE)
	_send_weblobby()
	
	WEB_LOBBY_KNOWN_REQUESTS.erase(steam_id)
	
	emit_signal("_weblobby_request_update")
	Steam.sendLobbyChatMsg(STEAM_LOBBY_ID, "$weblobby_request_accepted-" + str(steam_id))
	if send_notif: PlayerData._send_notification("Player request accepted.")


func _deny_user_into_weblobby(steam_id, reason = DENY_REASONS.DENIED, send_notif = true, ban_player = true):
	WEB_LOBBY_JOIN_QUEUE.erase(steam_id)
	if ban_player and not WEB_LOBBY_REJECTS.has(steam_id):
		_ban_player(steam_id)
	
	emit_signal("_weblobby_request_update")
	match reason:
		DENY_REASONS.DENIED: Steam.sendLobbyChatMsg(STEAM_LOBBY_ID, "$weblobby_request_denied_deny-" + str(steam_id))
		DENY_REASONS.LOBBY_FULL: Steam.sendLobbyChatMsg(STEAM_LOBBY_ID, "$weblobby_request_denied_full-" + str(steam_id))
	if send_notif: PlayerData._send_notification("Player request denied.")


func _remove_player_from_weblobby(steam_id, reason):
	_user_left_weblobby(steam_id, reason)
	_send_P2P_Packet({"type": "user_left_weblobby", "user_id": steam_id, "reason": reason})



func _user_joined_weblobby(steam_id):
	if WEB_LOBBY_MEMBERS.has(steam_id): return
	
	WEB_LOBBY_MEMBERS.append(steam_id)
	_connect_to_lobby_member(steam_id)
	_recieve_safe_message(steam_id, "ffeed5", "%u joined the game.", false)


func _user_left_weblobby(steam_id, reason = DC_REASONS.USER_LEAVE):
	if not WEB_LOBBY_MEMBERS.has(steam_id): return
	
	var text = ""
	match reason:
		DC_REASONS.USER_LEAVE: text = "%u left the game."
		DC_REASONS.USER_KICK: text = "%u was kicked from the game."
		DC_REASONS.USER_BAN: text = "%u was banned from the game."
	
	WEB_LOBBY_MEMBERS.erase(steam_id)
	_close_session(steam_id)
	_recieve_safe_message(steam_id, "ffeed5", text, false)
	_send_weblobby()
	
	for actor in get_tree().get_nodes_in_group("actor"):
		if actor.owner_id == steam_id: actor.queue_free()


func _accepted_into_weblobby():
	print("Accepted into WEBLOBBY")
	IN_WEB_LOBBY = true
	_connect_to_lobby_member(Steam.getLobbyOwner(STEAM_LOBBY_ID))

func _denied_into_weblobby(reason = DENY_REASONS.DENIED):
	print("Denied into WEBLOBBY")
	emit_signal("_denied_into_weblobby_signal", reason)

func _send_weblobby():
	if STEAM_ID != Steam.getLobbyOwner(STEAM_LOBBY_ID): return
	_send_P2P_Packet({"type": "receive_weblobby", "weblobby": WEB_LOBBY_MEMBERS}, "steamlobby", 2, CHANNELS.GAME_STATE)

func _receive_weblobby(web_lobby):
	print("Received Weblobby")
	WEB_LOBBY_MEMBERS = web_lobby
	
	for member in WEB_LOBBY_MEMBERS:
		_connect_to_lobby_member(member)





func _create_custom_lobby(type, player_limit, tags, display_name, request = false):
	_reset_lobby_status()
	GAME_MASTER = true
	
	WEB_LOBBY_AUTO_ACCEPT = request
	
	if LOBBY_TYPE_DATA[type].offline:
		PLAYING_OFFLINE = true
	else:
		PLAYING_OFFLINE = false
		_create_Lobby(type, player_limit, tags, display_name)
		await self._connected_to_lobby
	
	Globals._enter_game()
	print("Creating Lobby")

func _create_Lobby(type, player_limit = 12, tags = [], display_name = ""):
	_leave_lobby()
	_reset_lobby_status()
	_reset_network_socket()
	_setup_new_weblobby()
	
	if STEAM_LOBBY_ID > 0: return
	GAME_MASTER = true
	
	var lobby_type_data = LOBBY_TYPE_DATA[type]
	var lobby_type = lobby_type_data.lobby_type
	
	SERVER_CREATION_TYPE = type
	SERVER_SETUP_TAGS = tags
	SERVER_SETUP_CAP = player_limit
	SERVER_SETUP_TITLE = display_name
	CREATING_SERVER = true
	WEB_LOBBY_MAX_USERS = player_limit
	Steam.createLobby(lobby_type, 50)
	print("Creating Lobby with a ", player_limit, " player cap.")

func _on_Lobby_Created(connect, lobby_id):
	if connect != 1: return
	
	randomize()
	var code = ""
	var characters = "abcdefghijklmnopqrstuvwxyz1234567890"
	for i in 6:
		code += characters[randi() % characters.length()]
	code = code.to_upper()
	LOBBY_CODE = code
	
	
	var lobby_type_data = LOBBY_TYPE_DATA[SERVER_CREATION_TYPE]
	var public = "true" if lobby_type_data.browser_visible else "false"
	var request = "true" if not WEB_LOBBY_AUTO_ACCEPT else "false"
	
	PLAYING_OFFLINE = false
	CODE_ENABLED = lobby_type_data.code_button
	_reset_network_socket()
	
	STEAM_LOBBY_ID = lobby_id
	_update_chat("Created Lobby.")
	Steam.setLobbyJoinable(lobby_id, true)
	
	Steam.setLobbyData(lobby_id, "name", str(STEAM_USERNAME))
	Steam.setLobbyData(lobby_id, "lobby_name", str(SERVER_SETUP_TITLE))
	Steam.setLobbyData(lobby_id, "ref", "webfishing_gamelobby")
	Steam.setLobbyData(lobby_id, "version", str(Globals.GAME_VERSION))
	Steam.setLobbyData(lobby_id, "code", code)
	Steam.setLobbyData(lobby_id, "type", str(SERVER_CREATION_TYPE))
	Steam.setLobbyData(lobby_id, "request", request)
	Steam.setLobbyData(lobby_id, "public", public)
	
	Steam.setLobbyData(lobby_id, "cap", str(SERVER_SETUP_CAP))
	Steam.setLobbyData(lobby_id, "count", str(1))
	
	
	for tag in LOBBY_TAGS:
		Steam.setLobbyData(lobby_id, "tag_" + tag, "1" if SERVER_SETUP_TAGS.has(tag) else "0")
	
	
	Steam.setLobbyData(lobby_id, "server_browser_value", str(randi() % 20))


func _join_Lobby(lobby_id):
	var in_lobby = await _leave_lobby()
	if not in_lobby: _reset_network_socket()
	_reset_lobby_status()
	_clear_weblobby()
	
	STEAM_LOBBY_ID = lobby_id
	await get_tree().create_timer(1.0).timeout
	Steam.joinLobby(lobby_id)

func _connect_to_lobby(id):
	var LOBBY_VERSION = Steam.getLobbyData(id, "version")
	print("Game Ver: ", LOBBY_VERSION)
	
	if LOBBY_VERSION != "" and str(LOBBY_VERSION) != str(Globals.GAME_VERSION):
		PopupMessage._show_popup("Game Version does not match lobby's version")
		Globals._exit_game()
		return
	
	PLAYING_OFFLINE = false
	_join_Lobby(id)
	Globals._enter_game()

func _on_Lobby_Joined(lobby_id, _perms, _locked, response):
	print("Lobby Join Response: ", response)
	if response == 1:
		STEAM_LOBBY_ID = lobby_id
		LOBBY_CODE = Steam.getLobbyData(lobby_id, "code")
		
		PlayerData.player_saved_position = Vector3.ZERO
		PlayerData.player_saved_zone = ""
		if GAME_MASTER: KNOWN_GAME_MASTER = STEAM_ID
		else: KNOWN_GAME_MASTER = Steam.getLobbyOwner(lobby_id)
		
		var lobby_type = int(Steam.getLobbyData(STEAM_LOBBY_ID, "type"))
		CODE_ENABLED = LOBBY_TYPE_DATA[lobby_type].code_button
		
		_update_chat("Joined Lobby.")
		_get_lobby_members(true)
		emit_signal("_connected_to_lobby")
	
	else:
		_update_chat("Error Joining Lobby!")

func _leave_lobby():
	if STEAM_LOBBY_ID > 0:
		if GAME_MASTER:
			_host_left_lobby()
			await get_tree().create_timer(1.0).timeout
		
		_close_all_connections()
		_reset_network_socket()
		
		_update_chat("Leaving lobby.")
		Steam.leaveLobby(STEAM_LOBBY_ID)
		STEAM_LOBBY_ID = 0
		
		LOBBY_MEMBERS.clear()
		return true
	return false

func _get_lobby_members(chat = false):
	LOBBY_MEMBERS.clear()
	
	
	var user_count = 0
	var valid_ids = []
	
	var MEMBERS = Steam.getNumLobbyMembers(STEAM_LOBBY_ID)
	for MEMBER in range(0, MEMBERS):
		var MEMBER_ID = Steam.getLobbyMemberByIndex(STEAM_LOBBY_ID, MEMBER)
		var MEMBER_NAME = Steam.getFriendPersonaName(MEMBER_ID)
		_add_lobby_member(MEMBER_ID, MEMBER_NAME)
		
		valid_ids.append(MEMBER_ID)
		if MEMBER_ID == STEAM_ID: user_count += 1
	emit_signal("_members_updated")
	
	for open_id in OPEN_CONNECTIONS:
		if not valid_ids.has(open_id):
			_close_session(open_id)
	
	if user_count >= 2:
		PlayerData._send_notification("Duplicate Steam ID Found. Returning to Menu.", 1)
		Globals._exit_game()

func _add_lobby_member(steam_id, steam_name):
	LOBBY_MEMBERS.append({"steam_id": steam_id, "steam_name": steam_name, "ping": - 1})

func _on_Lobby_Chat_Update(lobby_id, changed_id, making_change_id, chat_state):
	print("[STEAM] Lobby ID: " + str(lobby_id) + ", Changed ID: " + str(changed_id) + ", Making Change: " + str(making_change_id) + ", Chat State: " + str(chat_state))
	
	
	if chat_state == 1:
		emit_signal("_user_connected", making_change_id)
	
	
	elif chat_state == 2:
		emit_signal("_user_disconnected", making_change_id)
		_remove_player_from_weblobby(making_change_id, DC_REASONS.USER_LEAVE)
		_close_session(making_change_id)
		
		WEB_LOBBY_JOIN_QUEUE.erase(making_change_id)
		emit_signal("_weblobby_request_update")
	
	_get_lobby_members()

func _delayed_chat_update_message(user_id, message, delay):
	await get_tree().create_timer(delay).timeout
	_recieve_safe_message(user_id, "ffeed5", message, false)





func _on_Lobby_Join_Requested(lobby_id, friend_id):
	JOIN_ID_PROMPT = lobby_id
	_lobby_join_prompted(lobby_id)

func _lobby_join_prompted(lobby_id):
	print("NETWORK PROPMPT: ", lobby_id)
	if lobby_id == - 1: return
	
	if UserSave.current_loaded_slot == - 1:
		lobby_id = - 1
		return
	
	emit_signal("_menu_button_disable")
	_connect_to_lobby(lobby_id)
	
	JOIN_ID_PROMPT = - 1






func _connect_to_all_lobby_members():
	print("Connecting to all lobby members")
	for member in LOBBY_MEMBERS:
		_connect_to_lobby_member(member["steam_id"])
	
	await get_tree().create_timer(0.5).timeout
	_make_P2P_handshake()

func _connect_to_lobby_member(steam_id, follow_weblobby = false):
	if OPEN_CONNECTIONS.has(steam_id) or steam_id == STEAM_ID: return
	if follow_weblobby and not WEB_LOBBY_MEMBERS.has(steam_id): return
	
	_create_identity(steam_id)
	
	var player_id = PLAYER_NICKNAME_PREFIX + str(steam_id)
	var status = Steam.connectP2P(player_id, VIRTUAL_PORT, {})
	print("P2P Connection Status w user ", player_id, ": ", status)
	
	OPEN_CONNECTIONS.append(steam_id)
	_make_P2P_handshake(str(steam_id))

func _retry_connections():
	print("Retrying Connections.")
	var old_open_connections = OPEN_CONNECTIONS.duplicate()
	_close_all_connections()
	
	for connection in old_open_connections:
		_connect_to_lobby_member(connection)

func _create_identity(steam_id):
	if steam_id == STEAM_ID: return
	
	var player_id = PLAYER_NICKNAME_PREFIX + str(steam_id)
	#if Steam.addIdentity(player_id):
		#Steam.setIdentitySteamID64(player_id, steam_id)
		#_make_P2P_handshake()
		#print("Identity created for ", steam_id)
	#else:
		#print("Identity failed to create for ", steam_id)

func _session_request(identity):
	print("SESSION REQUEST FROM ", identity)
	print("IN LOBBY:", STEAM_LOBBY_ID)
	
	if STEAM_LOBBY_ID <= 0:
		Steam.closeSessionWithUser(identity)
		print("Session request closed, not in a steam lobby.")
		return
	
	
	
	var valid = STEAM_LOBBY_ID > 0 and WEB_LOBBY_MEMBERS.has(int(identity))
	
	var lobby_has_member = false
	for lobby_member in LOBBY_MEMBERS:
		if lobby_member["steam_id"] == int(identity):
			lobby_has_member = true
			break
	if not lobby_has_member: valid = false
	
	if not valid:
		print("Session Request DENIED")
		Steam.closeSessionWithUser(identity)
	else:
		print("Session Request ACCEPTED")
		Steam.acceptSessionWithUser(identity)

func _close_all_connections():
	for connection in OPEN_CONNECTIONS:
		_close_session(connection)

func _close_session(steam_id):
	print("Closing Session with ", steam_id)
	var identity = PLAYER_NICKNAME_PREFIX + str(steam_id)
	Steam.closeSessionWithUser(identity)
	#Steam.clearIdentity(identity)
	OPEN_CONNECTIONS.erase(steam_id)

func _make_P2P_handshake(target = "all", attempts = 8):
	for i in attempts:
		_send_P2P_Packet({"type": "handshake"}, target, 0, CHANNELS.GAME_STATE)
		await get_tree().create_timer(0.1).timeout

func _find_all_webfishing_lobbies(tags = [], must_match = false):
	var total_lobbies = []
	
	var nulls = 0
	
	for search_filter in 20:
		print("Searching filter ", search_filter)
		Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
		Steam.addRequestLobbyListStringFilter("public", "true", Steam.LOBBY_COMPARISON_EQUAL)
		
		for tag in LOBBY_TAGS:
			var has = 1 if tags.has(tag) else 0
			
			if must_match:
				Steam.addRequestLobbyListNumericalFilter("tag_" + str(tag), has, Steam.LOBBY_COMPARISON_EQUAL)
			else:
				if tags.has(tag):
					Steam.addRequestLobbyListNumericalFilter("tag_" + str(tag), 1, Steam.LOBBY_COMPARISON_EQUAL_TO_OR_LESS_THAN)
				else:
					Steam.addRequestLobbyListNumericalFilter("tag_" + str(tag), 0, Steam.LOBBY_COMPARISON_EQUAL_TO_OR_LESS_THAN)
		
		search_filter -= 1
		if search_filter != - 1: Steam.addRequestLobbyListStringFilter("server_browser_value", str(search_filter), Steam.LOBBY_COMPARISON_EQUAL)
		
		var goal = Time.get_unix_time_from_system() - 20.0
		Steam.addRequestLobbyListNumericalFilter("timestamp", goal, Steam.LOBBY_COMPARISON_EQUAL_TO_GREATER_THAN)
		
		Steam.requestLobbyList()
		var lobbies = await Steam.lobby_match_list
		print(lobbies.size(), " Lobbies found for Filter ", search_filter)
		
		if lobbies.size() <= 0:
			nulls += 1
			if nulls > 3: break
		
		total_lobbies.append_array(lobbies)
	
	print(total_lobbies.size(), " servers found.")
	emit_signal("_webfishing_lobbies_returned", total_lobbies)
	return total_lobbies

func _search_for_lobby(code):
	var lobby_found = - 1
	
	code = code.to_upper()
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.addRequestLobbyListStringFilter("code", str(code), Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()
	var lobbies = await Steam.lobby_match_list
	
	var sanitized_list = []
	for lobby in lobbies:
		var players = Steam.getNumLobbyMembers(lobby)
		sanitized_list.append([lobby, players])
	sanitized_list.sort_custom(Callable(self, "_lobby_sort_random"))
	sanitized_list.sort_custom(Callable(self, "_lobby_sort_high"))
	
	if sanitized_list.size() > 0:
		var LOBBY = sanitized_list[0][0]
		lobby_found = LOBBY
	
	if lobby_found == - 1:
		PopupMessage._show_popup("No server found with code " + str(code))
		Globals._exit_game()
		return false
	else:
		_connect_to_lobby(lobby_found)
		print("Joining Lobby ", lobby_found)
		return true




func _set_server_browser_value():
	randomize()
	var value = randi() % 20
	print("Setting Server Browser Value to: ", value)
	Steam.setLobbyData(STEAM_LOBBY_ID, "server_browser_value", str(value))

func _get_username_from_id(id):
	if PLAYING_OFFLINE:
		return STEAM_USERNAME
	
	for member in LOBBY_MEMBERS:
		if member["steam_id"] == id:
			return member["steam_name"]
	return "null"

func _closing_app():
	if GAME_MASTER: _host_left_lobby()






func _kick_player(id):
	_send_P2P_Packet({"type": "client_was_kicked"}, str(id), 2, CHANNELS.GAME_STATE)
	_send_P2P_Packet({"type": "peer_was_kicked", "user_id": id}, "all", 2, CHANNELS.GAME_STATE)
	
	await get_tree().create_timer(0.2).timeout
	_user_left_weblobby(id, DC_REASONS.USER_KICK)
	PlayerData._send_notification("Player kicked.")

func _ban_player(id):
	_send_P2P_Packet({"type": "client_was_banned"}, str(id), 2, CHANNELS.GAME_STATE)
	_send_P2P_Packet({"type": "peer_was_banned", "user_id": id}, "all", 2, CHANNELS.GAME_STATE)
	
	await get_tree().create_timer(0.2).timeout
	_user_left_weblobby(id, DC_REASONS.USER_BAN)
	PlayerData._send_notification("Player banned.")
	WEB_LOBBY_REJECTS.append(id)
	
	emit_signal("_members_updated")

func _unban_player(id):
	WEB_LOBBY_REJECTS.erase(id)
	PlayerData._send_notification("Player un-banned.")
	emit_signal("_members_updated")

func _request_actors():
	if PLAYING_OFFLINE or STEAM_LOBBY_ID <= 0: return
	_send_P2P_Packet({"type": "request_actors", "user_id": str(STEAM_ID)}, "peers", 2, CHANNELS.GAME_STATE)

func _create_replication_data(id):
	var data = []
	
	for actor in OWNED_ACTORS:
		if not is_instance_valid(actor): continue
		var new_data = actor._request_saved_data()
		data.append(new_data)
	
	print("Sending all owned Actors to ", str(id), " data: ", data)
	_send_P2P_Packet({"type": "actor_request_send", "list": data}, str(id), 2, CHANNELS.GAME_STATE)

func _replicate_actors(list, from):
	if REPLICATIONS_RECIEVED.has(from):
		print("Replication Failed")
		return
	
	print("Recieved actors: ", list)
	
	var existing_actor_ids = []
	for actor in get_tree().get_nodes_in_group("actor"):
		existing_actor_ids.append(actor.actor_id)
	REPLICATIONS_RECIEVED.append(from)
	
	for actor in list:
		if existing_actor_ids.has(actor["id"]):
			print("Actor Already Exists, skipping!")
			continue
		
		var dict = {"actor_type": actor["type"], "at": Vector3.ZERO, "rot": Vector3.ZERO, "zone": "", "zone_owner": - 1, "actor_id": actor["id"], "creator_id": actor["owner"], "data": {}}
		emit_signal("_instance_actor", dict, from)

func _sync_create_actor(actor_type, at, zone, id = - 1, creator = STEAM_ID, rotation = Vector3.ZERO, zone_owner = - 1):
	randomize()
	if id == - 1: id = randi()
	var dict = {"actor_type": actor_type, "at": at, "zone": zone, "actor_id": id, "creator_id": creator, "rot": rotation, "zone_owner": zone_owner}
	_send_P2P_Packet({"type": "instance_actor", "params": dict}, "peers", 2, CHANNELS.GAME_STATE)
	emit_signal("_instance_actor", dict)
	return id

func _send_actor_animation_update(actor_id, data):
	_send_P2P_Packet({"type": "actor_animation_update", "actor_id": actor_id, "data": data}, "peers", 0, CHANNELS.ACTOR_ANIMATION)

func _send_actor_action(id, action, params = [], all = true, channel = CHANNELS.ACTOR_ACTION):
	var target = "all" if all else "peers"
	_send_P2P_Packet({"type": "actor_action", "actor_id": id, "action": action, "params": params}, target, 2, channel)

func _send_message(message, color, local = false):
	if not _message_cap(STEAM_ID):
		_update_chat("Sending too many messages too quickly!", false)
		_update_chat("Sending too many messages too quickly!", true)
		return
	
	var msg_pos = MESSAGE_ORIGIN.round()
	
	_recieve_safe_message(STEAM_ID, color, message, local)
	_send_P2P_Packet({"type": "message", "message": message, "color": color, "local": local, "position": MESSAGE_ORIGIN, "zone": MESSAGE_ZONE, "zone_owner": PlayerData.player_saved_zone_owner}, "peers", 2, CHANNELS.GAME_STATE)

func _host_left_lobby():
	_send_P2P_Packet({"type": "server_close"}, "peers", 2, CHANNELS.GAME_STATE)

func _replication_check():
	for lobby_member in LOBBY_MEMBERS:
		if lobby_member["steam_id"] == STEAM_ID: continue
		if not REPLICATIONS_RECIEVED.has(lobby_member["steam_id"]):
			print("Missing Replication from: ", lobby_member["steam_id"])
			_send_P2P_Packet({"type": "request_actors", "user_id": str(STEAM_ID)}, str(lobby_member["steam_id"]), 2, CHANNELS.GAME_STATE)





func _send_P2P_Packet(packet_data, target = "all", type = 0, channel = 0):
	if PLAYING_OFFLINE or STEAM_LOBBY_ID <= 0: return
	
	var CHANNEL: int = channel
	var PACKET_DATA: PackedByteArray = []
	
	var SEND_TYPE: int = type
	match type:
		0: SEND_TYPE = Steam.NETWORKING_SEND_UNRELIABLE
		2: SEND_TYPE = Steam.NETWORKING_SEND_RELIABLE
	
	PACKET_DATA.append_array(var_to_bytes(packet_data).compress(COMPRESSION_TYPE))
	
	if target == "all":
		for MEMBER in WEB_LOBBY_MEMBERS:
			_send_p2p_message(int(MEMBER), PACKET_DATA, SEND_TYPE, CHANNEL)
	elif target == "peers":
		for MEMBER in WEB_LOBBY_MEMBERS:
			if MEMBER != STEAM_ID:
				_send_p2p_message(int(MEMBER), PACKET_DATA, SEND_TYPE, CHANNEL)
	elif target == "steamlobby":
		for MEMBER in LOBBY_MEMBERS:
			_send_p2p_message(int(MEMBER["steam_id"]), PACKET_DATA, SEND_TYPE, CHANNEL, false)
	else:
		_send_p2p_message(int(target), PACKET_DATA, SEND_TYPE, CHANNEL)

func _send_p2p_message(player_id, PACKET_DATA, SEND_TYPE, CHANNEL, WEBLOBBY_FORCE = true):
	
	
	var FINAL_NAME = PLAYER_NICKNAME_PREFIX + str(player_id)
	Steam.sendMessageToUser(FINAL_NAME, PACKET_DATA, SEND_TYPE, CHANNEL)



func _read_P2P_Packet(message_data = {}):
	if PLAYING_OFFLINE or STEAM_LOBBY_ID <= 0: return
	
	
	var PACKET_SIZE: int = message_data["payload"].size()
	
	if PACKET_SIZE > 0:
		var PACKET: Dictionary = message_data
		
		if not PACKET.keys().has("identity") or not PACKET.keys().has("payload"):
			print("Packet Disregarded! Invalid Packet Structure")
			return
		
		var PACKET_SENDER: int = int(PACKET["identity"])
		
		if PlayerData.players_hidden.has(PACKET_SENDER):
			return
		
		if not OPEN_CONNECTIONS.has(PACKET_SENDER):
			print("Packet Disregarded! This freak aint supposed to be here!")
			return
		
		if not PACKET_TIMEOUTS.is_empty() and PACKET_TIMEOUTS.has(PACKET_SENDER):
			print("Packet Disregarded! User is in timeout babyjail!")
			return
		
		if PACKET.is_empty(): print("Error! Empty Packet!")
		
		var decomp = PACKET.payload.decompress_dynamic( - 1, COMPRESSION_TYPE)
		var DATA = bytes_to_var(decomp)
		var type: String = DATA["type"]
		
		var from_host = Steam.getLobbyOwner(STEAM_LOBBY_ID) == PACKET_SENDER
		
		if not FLUSH_PACKET_INFORMATION.keys().has(PACKET_SENDER):
			FLUSH_PACKET_INFORMATION[PACKET_SENDER] = 1
		FLUSH_PACKET_INFORMATION[PACKET_SENDER] += 1
		
		
		
		
		
		
		
		
		
		match type:
			
			"handshake":
				print("Handshake Recieved! :3 P2P Connection has been proc'd")
				_send_weblobby()
			
			
			"server_close":
				if not from_host: return
				PopupMessage._show_popup("Host left the game.")
				Globals._exit_game()
			
			
			"peer_was_kicked":
				if not from_host: return
				_user_left_weblobby(DATA["user_id"], DC_REASONS.USER_KICK)
			"client_was_kicked":
				if not from_host: return
				PopupMessage._show_popup("You were kicked from the game.")
				Globals._exit_game()
			
			
			"peer_was_banned":
				if not from_host: return
				_user_left_weblobby(DATA["user_id"], DC_REASONS.USER_BAN)
			"client_was_banned":
				if not from_host: return
				PopupMessage._show_popup("You were banned from the game.")
				Globals._exit_game()
			
			
			"request_actors":
				if not _validate_packet_information(DATA, ["user_id"], [TYPE_STRING]): return
				_create_replication_data(int(DATA["user_id"]))
			"actor_request_send":
				if not _validate_packet_information(DATA, ["list"], [TYPE_ARRAY]): return
				_replicate_actors(DATA["list"], int(PACKET_SENDER))
			
			"instance_actor":
				if not _validate_packet_information(DATA, ["params"], [TYPE_DICTIONARY]): return
				
				
				var amt = 0
				for actor in get_tree().get_nodes_in_group("actor"):
					if actor.owner_id == PACKET_SENDER: amt += 1
				
				if amt > MAX_OWNED_ACTOR_LIMIT:
					print("Actor disregarded, too many actors owned under ID")
					return
				
				DATA["params"]["creator_id"] = PACKET_SENDER
				emit_signal("_instance_actor", DATA["params"], PACKET_SENDER)
			
			
			"actor_update":
				if not _validate_packet_information(DATA, ["actor_id", "pos", "rot"], [TYPE_INT, TYPE_VECTOR3, TYPE_VECTOR3]): return
				ACTOR_DATA[DATA["actor_id"]] = {"pos": DATA["pos"], "rot": DATA["rot"]}
			"actor_animation_update":
				if not _validate_packet_information(DATA, ["actor_id", "data"], [TYPE_INT, TYPE_ARRAY]): return
				if not _validate_array(DATA["data"], true, [TYPE_VECTOR3, TYPE_BOOL, TYPE_BOOL, TYPE_BOOL, TYPE_BOOL, TYPE_STRING, TYPE_DICTIONARY, TYPE_INT, TYPE_INT, TYPE_FLOAT, TYPE_FLOAT, TYPE_FLOAT, TYPE_FLOAT, TYPE_FLOAT, TYPE_FLOAT, TYPE_FLOAT, TYPE_FLOAT, TYPE_INT, TYPE_INT, TYPE_BOOL, TYPE_BOOL, TYPE_BOOL, TYPE_BOOL, TYPE_BOOL]): return
				ACTOR_ANIMATION_DATA[DATA["actor_id"]] = DATA["data"]
			"actor_action":
				if not _validate_packet_information(DATA, ["actor_id", "action", "params"], [TYPE_INT, TYPE_STRING, TYPE_ARRAY]): return
				if PACKET_SENDER == STEAM_ID: return
				
				if not _validate_array(DATA["params"]): return
				
				if not ACTOR_ACTIONS.keys().has(DATA["actor_id"]):
					ACTOR_ACTIONS[DATA["actor_id"]] = []
				if ACTOR_ACTIONS[DATA["actor_id"]].size() > 128:
					print(DATA["actor_id"], " Too many actor actions queued. Disregarding.")
					print("Packet Dump: ", ACTOR_ACTIONS[DATA["actor_id"]])
					return
				ACTOR_ACTIONS[DATA["actor_id"]].append([DATA["action"], DATA["params"], PACKET_SENDER])
			
			"message":
				if PlayerData.players_muted.has(PACKET_SENDER) or PlayerData.players_hidden.has(PACKET_SENDER): return
				
				if not _validate_packet_information(DATA, ["message", "color", "local", "position", "zone", "zone_owner"], [TYPE_STRING, TYPE_STRING, TYPE_BOOL, TYPE_VECTOR3, TYPE_STRING, TYPE_INT]): return
				
				if not _message_cap(PACKET_SENDER): return
				
				var user_id: int = PACKET_SENDER
				var user_color: String = DATA["color"].left(12).replace("[", "")
				var user_message: String = DATA["message"]
				
				if not DATA["local"]:
					_recieve_safe_message(user_id, user_color, user_message, false)
				else:
					var dist = DATA["position"].distance_to(MESSAGE_ORIGIN)
					if DATA["zone"] == MESSAGE_ZONE and DATA["zone_owner"] == PlayerData.player_saved_zone_owner:
						if dist < 25.0: _recieve_safe_message(user_id, user_color, user_message, true)
			
			"letter_recieved":
				if PlayerData.players_muted.has(PACKET_SENDER) or PlayerData.players_hidden.has(PACKET_SENDER): return
				
				if str(STEAM_ID) == DATA["to"]:
					if not _validate_packet_information(DATA["data"], ["letter_id", "header", "closing", "body", "items", "to", "from"], [TYPE_INT, TYPE_STRING, TYPE_STRING, TYPE_STRING, TYPE_ARRAY, TYPE_STRING, TYPE_STRING]): return
					PlayerData._recieved_letter(DATA["data"])
			"letter_was_accepted":
				PlayerData._letter_was_accepted()
			"letter_was_denied":
				PlayerData._letter_was_denied()
			
			"chalk_packet":
				if PlayerData.players_muted.has(PACKET_SENDER) or PlayerData.players_hidden.has(PACKET_SENDER): return
				if not _validate_packet_information(DATA, ["data", "canvas_id"], [TYPE_ARRAY, TYPE_INT]): return
				
				PlayerData.emit_signal("_chalk_recieve", DATA["data"], DATA["canvas_id"])
			"new_player_join":
				emit_signal("_new_player_join", PACKET_SENDER)
				emit_signal("_new_player_join_empty")
			
			"player_punch":
				if not _validate_packet_information(DATA, ["from_pos", "punch_type"], [TYPE_VECTOR3, TYPE_INT]): return
				
				if PlayerData.players_hidden.has(PACKET_SENDER): return
				PlayerData.emit_signal("_punched", DATA["from_pos"], DATA["punch_type"])
			
			
			
			"user_joined_weblobby":
				if not from_host: return
				_user_joined_weblobby(DATA["user_id"])
			
			"user_left_weblobby":
				if not from_host: return
				_user_left_weblobby(DATA["user_id"])
			
			"receive_weblobby":
				if not from_host: return
				_receive_weblobby(DATA["weblobby"])




func _validate_packet_information(data: Dictionary, information_keys: Array, information_types: Array):
	var valid = true
	
	var index = 0
	for key in information_keys:
		if data.keys().has(key):
			var type = typeof(data[key])
			
			if type != information_types[index]:
				valid = false
				break
			
			if type == TYPE_VECTOR3 and is_nan(data[key].length()):
				valid = false
				break
			if type == TYPE_INT and is_nan(data[key]):
				valid = false
				break
			
		else:
			valid = false
			break
		index += 1
	
	if not valid:
		print(data)
		print("Packet is invalid.")
	
	if false: print("you cant read comments if you decompile so im letting anyone here know that im quite aware this is all shit but it is what it is!!!")
	return valid

func _validate_array(array, match_use = false, matching_array = []):
	var valid = true
	
	var index = 0
	for entry in array:
		var type = typeof(entry)
		
		if type == TYPE_VECTOR3 and is_nan(entry.length()):
			valid = false
			break
		if type == TYPE_INT and is_nan(entry):
			valid = false
			break
		
		if match_use and typeof(entry) != matching_array[index]:
			valid = false
			break
		
		index += 1
	
	if not valid:
		print(array)
		print("Array is invalid.")
	
	return valid





func _packet_flush():
	PACKET_TIMEOUTS.clear()
	for key in FLUSH_PACKET_INFORMATION.keys():
		if FLUSH_PACKET_INFORMATION[key] >= MAX_PACKET_TIMEOUT_LIMIT:
			PACKET_TIMEOUTS.append(key)
		if FLUSH_PACKET_INFORMATION[key] >= MAX_MAJOR_PACKET_TIMEOUT_LIMIT:
			if GAME_MASTER and Steam.getLobbyOwner(STEAM_LOBBY_ID) == STEAM_ID:
				PlayerData._send_notification("player sending too far many packets, kicking them.")
				_kick_player(int(key))
		FLUSH_PACKET_INFORMATION[key] = 0

func _message_flush():
	for key in MESSAGE_COUNT_TRACKER.keys():
		MESSAGE_COUNT_TRACKER[key] -= 1
		if MESSAGE_COUNT_TRACKER[key] <= 0:
			MESSAGE_COUNT_TRACKER.erase(key)

func _message_cap(id):
	if not MESSAGE_COUNT_TRACKER.keys().has(id):
		MESSAGE_COUNT_TRACKER[id] = 0
	if MESSAGE_COUNT_TRACKER[id] > 10: return false
	MESSAGE_COUNT_TRACKER[id] += 1
	
	return true

func _lobby_sort_high(a, b): return a[1] > b[1]
func _lobby_sort_random(a, b): return randf() < 0.5
