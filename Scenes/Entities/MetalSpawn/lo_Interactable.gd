extends Interactable

func _activate(actor):
	var id = get_parent().actor_id
	
	actor._wipe_actor(id)
	Network._send_actor_action(actor.actor_id, "_wipe_actor", [id])
	
	var item_roll = Globals._roll_loot_table("metal")
	var data = Globals.item_data[item_roll]["file"]
	var size = data.average_size
	
	var ref = PlayerData._add_item(item_roll, - 1, size)
	actor._obtain_item(ref, [], false)
	monitorable = false
