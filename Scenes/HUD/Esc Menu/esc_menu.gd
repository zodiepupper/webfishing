extends Control

var code_shown = false
var open = false
var hovered_button = null

onready var buttonlist = $VBoxContainer
onready var invite_box = $"%invite_box"

signal _close

func _ready():
	for child in buttonlist.get_children():
		if child is Button:
			child.connect("mouse_entered", self, "_hover_button", [child])
			child.connect("mouse_exited", self, "_exit_button", [child])
			child.add_to_group("menu_button")
	
	$HBoxContainer / Label.text = "lamedeveloper v" + str(Globals.GAME_VERSION)

func _process(delta):
	$VBoxContainer / code_show.visible = not code_shown and not Network.PLAYING_OFFLINE and Network.CODE_ENABLED
	$VBoxContainer / code_display.visible = code_shown
	$VBoxContainer / code_display / Panel / code.text = str(Network.LOBBY_CODE)
	$VBoxContainer / invite_friends.visible = not Network.PLAYING_OFFLINE
	
	for node in get_tree().get_nodes_in_group("menu_button"):
		node.size_flags_stretch_ratio = lerp(node.size_flags_stretch_ratio, 0.5 if hovered_button != node else 1.0, 0.1)
	
	$fade_bg.modulate.a = lerp($fade_bg.modulate.a, 0.2, 0.06)

func _hover_button(node):
	hovered_button = node
func _exit_button(node):
	hovered_button = null

func _open():
	$fade_bg.modulate.a = 0.0
	
	_exit_button(null)
	code_shown = false
	open = true

func _close():
	OptionsMenu._close()
	open = false




func _on_resume_pressed():
	emit_signal("_close")

func _on_code_pressed():
	code_shown = true

func _on_copy_paste_pressed():
	OS.set_clipboard(str(Network.LOBBY_CODE.to_upper()))

func _on_settings_pressed():
	OptionsMenu._open()

func _on_save_pressed():
	UserSave._quick_save()
	emit_signal("_close")

func _on_quit_pressed():
	UserSave._quick_save()
	Globals._exit_game()

func _on_quit_total_pressed():
	Globals._close_game(true)





func _open_invite_menu():
	Steam.activateGameOverlayInviteDialog(Network.STEAM_LOBBY_ID)

func _invite_friend(steam_id):
	var success = Steam.inviteUserToLobby(Network.STEAM_LOBBY_ID, steam_id)
	print("Inviting ", steam_id, " to lobby, Success: ", success)


func _on_fullscreen_pressed():
	OS.window_fullscreen = not OS.window_fullscreen
func _on_HSlider_drag_ended(value_changed):
	Globals.pixelize_amount = $VBoxContainer / HBoxContainer / HSlider.value
	get_tree().get_root().emit_signal("size_changed")
func _reset_pixel():
	$VBoxContainer / HBoxContainer / HSlider.value = 2.25
	_on_HSlider_drag_ended(true)
func _on_spawn_pressed():
	PlayerData.emit_signal("_return_to_spawn")

