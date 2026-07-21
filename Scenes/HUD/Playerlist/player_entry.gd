extends Control

var held_data = []

onready var player_name = $Panel / HBoxContainer / RichTextLabel
onready var ping_label = $Panel / HBoxContainer / member / ping

func _setup(data, type = 0):
	held_data = data
	player_name.text = str(data["steam_name"])
	
	var ping = 0
	if Network.PING_DICTIONARY.keys().has(data["steam_id"]):
		ping = Network.PING_DICTIONARY[data["steam_id"]]
	ping_label.text = "ping: " + str(ping)
	
	if data["steam_id"] == Network.KNOWN_GAME_MASTER: player_name.text = "[host] " + player_name.text
	
	$"%member".visible = type == 0
	$"%request".visible = type == 1
	$"%unban".visible = type == 2
	$"%unblock".visible = type == 3
	
	$Panel / HBoxContainer / member / mute.icon = preload("res://Assets/Textures/UI/player_options2.png") if PlayerData.players_muted.has(data["steam_id"]) else preload("res://Assets/Textures/UI/player_options1.png")
	$Panel / HBoxContainer / member / block.icon = preload("res://Assets/Textures/UI/player_options4.png") if PlayerData.players_hidden.has(data["steam_id"]) else preload("res://Assets/Textures/UI/player_options3.png")
	
	$Panel / HBoxContainer / member / mute.disabled = data["steam_id"] == Network.STEAM_ID
	$Panel / HBoxContainer / member / block.disabled = data["steam_id"] == Network.STEAM_ID
	
	$Panel / HBoxContainer / member / kick.disabled = not Network.GAME_MASTER or data["steam_id"] == Network.STEAM_ID
	$Panel / HBoxContainer / member / ban.disabled = not Network.GAME_MASTER or data["steam_id"] == Network.STEAM_ID

func _on_mute_pressed(): PlayerData._mute_player(held_data["steam_id"])
func _on_block_pressed(): PlayerData._hide_player(held_data["steam_id"])
func _on_kick_pressed(): if Network.GAME_MASTER: Network._kick_player(held_data["steam_id"])
func _on_ban_pressed(): if Network.GAME_MASTER: Network._ban_player(held_data["steam_id"])
func _on_steam_pressed(): if Network.STEAM_ENABLED: Steam.activateGameOverlayToUser("steamid", held_data["steam_id"])

func _on_accept_player_pressed(): Network._accept_user_into_weblobby(held_data["steam_id"])
func _on_deny_player_pressed(): Network._deny_user_into_weblobby(held_data["steam_id"])

func _on_unban_player_pressed(): Network._unban_player(held_data["steam_id"])
func _on_unblock_player_pressed(): PlayerData._unhide_player(held_data["steam_id"])
