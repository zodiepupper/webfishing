extends Control

onready var in_box = $letters / Panel / ScrollContainer / VBoxContainer

signal _create_letter
signal _read_letter

func _ready():
	PlayerData.connect("_letter_update", self, "_refresh")
	_refresh()

func _refresh():
	for child in in_box.get_children(): child.queue_free()
	
	$letters / Label2.text = "INBOX (" + str(PlayerData.inbound_mail.size()) + "/50)"
	
	for letter in PlayerData.inbound_mail:
		var l = preload("res://Scenes/HUD/Inbox/letter_entry.tscn").instance()
		l._setup(letter, true)
		l.connect("_accepted", self, "_view_mail", [letter])
		l.connect("_deleted", self, "_delete_mail", [letter])
		in_box.add_child(l)

func _create_letter():
	emit_signal("_create_letter")
func _view_mail(letter):
	emit_signal("_read_letter", letter)

func _accept_mail(letter):
	PlayerData._accept_letter(letter["letter_id"])
func _delete_mail(letter):
	PlayerData._deny_letter(letter["letter_id"])
