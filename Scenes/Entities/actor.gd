extends CharacterBody3D
class_name Actor

const NETWORK_LERP = 0.3

@export var delete_on_owner_disconnect = false
@export var has_shadow = false
@export var dead_actor = false
@export var _can_be_hidden = false
@export var decay = false
@export var decay_timer = 600
@export var packet_send_cooldown = - 1

var actor_id = - 1
@export var owner_id = - 1: set = _set_owner_id
var controlled = false
var hidden = false
var in_zone = true
var custom_data = {}
var current_zone = ""
var current_zone_owner = - 1
var remembered_zone = ""
var custom_saved_data = {}
var actor_type = ""
var packet_cooldown = 0
var requested_visbility = true

var networked_position: Vector3

var valid_actions = ["_wipe_actor", "queue_free", "_set_zone"]
var custom_valid_actions = []

var world
var shadow

signal _clearing

func _ready():
	add_to_group("actor")
	Network.connect("_user_disconnected", Callable(self, "_user_disconnect"))
	Network.connect("_network_tick", Callable(self, "_network_share"))
	PlayerData.connect("_mute_update", Callable(self, "_mute_update"))
	controlled = owner_id == Network.STEAM_ID
	
	if not dead_actor:
		if controlled: _setup_controlled()
		else: _setup_not_controlled()
	
	if has_shadow:
		shadow = preload("res://Scenes/Entities/Shadow/shadow.tscn").instantiate()
		add_child(shadow)
		shadow.position = Vector3.ZERO
	
	if controlled:
		var zone_sync_timer = Timer.new()
		zone_sync_timer.wait_time = 5.0
		zone_sync_timer.connect("timeout", Callable(self, "_sync_zone"))
		add_child(zone_sync_timer)
		zone_sync_timer.start()
	
	_mute_update()
	_sync_zone()

func _physics_process(delta):
	in_zone = dead_actor or (current_zone == world.active_zone and current_zone_owner == world.active_zone_owner)
	visible = in_zone and not hidden and requested_visbility
	
	if dead_actor: return
	
	if controlled: _controlled_process(delta)
	else:
		global_transform.origin = lerp(global_transform.origin, networked_position, NETWORK_LERP)
		_not_controlled_process(delta)
		
		
		if networked_position.distance_squared_to(global_transform.origin) > 128:
			global_transform.origin = networked_position
	
	_network_sync()
	
	if decay:
		decay_timer -= 1
		if decay_timer <= 0 and controlled:
			_deinstantiate(true)
		if decay_timer <= - 5:
			_deinstantiate(false)

func _user_disconnect(id):
	print(id, " has disconnected, ", owner_id)
	if id == owner_id:
		if delete_on_owner_disconnect: queue_free()
		else: _owner_dc()

func _deinstantiate(_sync):
	if not controlled: return
	emit_signal("_clearing")
	
	_custom_kill()
	
	if Network.OWNED_ACTORS.has(self): Network.OWNED_ACTORS.erase(self)
	if _sync: Network._send_actor_action(actor_id, "queue_free")
	queue_free()





func _set_owner_id(new_owner_id):
	controlled = new_owner_id == Network.STEAM_ID
	owner_id = new_owner_id



func _network_share():
	if not controlled or dead_actor: return
	if packet_send_cooldown > 0 and packet_cooldown > 0:
		packet_cooldown -= 1
		return
	packet_cooldown = packet_send_cooldown
	
	if current_zone != remembered_zone: _sync_zone()
	
	Network._send_P2P_Packet({"type": "actor_update", "actor_id": actor_id, "pos": global_transform.origin, "rot": rotation}, "peers", Network.CHANNELS.ACTOR_UPDATE)



func _network_sync():
	if controlled or dead_actor: return
	
	if Network.ACTOR_DATA.keys().has(actor_id):
		var data = Network.ACTOR_DATA[actor_id]
		if not is_nan(data["pos"].length()): networked_position = data["pos"]
		if not is_nan(data["rot"].length()): rotation = data["rot"]
	if Network.ACTOR_ANIMATION_DATA.keys().has(actor_id):
		var data = Network.ACTOR_ANIMATION_DATA[actor_id]
		set("shared_animation_data", data)
	
	_process_actions()

func _process_actions():
	if Network.ACTOR_ACTIONS.keys().has(actor_id):
		for action in Network.ACTOR_ACTIONS[actor_id]:
			if action[2] != owner_id: continue
			if has_method(action[0]):
				if action[1] is Dictionary:
					action[1] = [action[1]]
				
				if valid_actions.has(action[0]) or custom_valid_actions.has(action[0]):
					callv(action[0], action[1])
		
		Network.ACTOR_ACTIONS[actor_id].clear()


func _request_saved_data():
	var data = {"type": actor_type, "id": actor_id, "owner": owner_id}
	return data




func _sync_zone():
	if dead_actor or not controlled: return
	
	remembered_zone = current_zone
	Network._send_actor_action(actor_id, "_set_zone", [current_zone, current_zone_owner])

func _set_zone(zone, zone_owner):
	if dead_actor or controlled: return
	
	current_zone = zone
	current_zone_owner = zone_owner





func _mute_update():
	hidden = PlayerData.players_hidden.has(owner_id) and _can_be_hidden




func _setup_controlled(): pass
func _setup_not_controlled(): pass

func _controlled_process(delta): pass
func _not_controlled_process(delta): pass

func _owner_dc(): pass
func _custom_kill(): pass
