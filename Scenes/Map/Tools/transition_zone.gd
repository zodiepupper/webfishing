extends Interactable

@export var zone_id = ""
@export var spawn_id = ""
@export var zone_owner = - 1
@export var cash_require = - 1
@export var use_text = ""

func _activate(actor):
	if cash_require > - 1:
		if PlayerData.money < cash_require:
			PlayerData._send_notification("You must make at least $1 from fish before you're allowed to leave!", 1)
			return
	
	actor.locked = true
	SceneTransition._fake_scene_change()
	await SceneTransition._finished
	actor._enter_zone(zone_id, spawn_id, zone_owner)
	await get_tree().create_timer(0.3).timeout
	if use_text != "": Network._update_chat(use_text)
	actor.locked = false
	actor._enter_state(0)
	actor._exit_animation()
