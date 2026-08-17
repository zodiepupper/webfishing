extends SubViewportContainer

const ACTOR_BANK = {
	"player": [preload("res://Scenes/Entities/Player/player.tscn"), false, 1], 
	"fish_spawn": [preload("res://Scenes/Entities/FishSpawn/fish_spawn.tscn"), true, 16], 
	"fish_spawn_alien": [preload("res://Scenes/Entities/MeteorSpawn/meteor_spawn.tscn"), true, 4], 
	"raincloud": [preload("res://Scenes/Entities/RainCloud/raincloud.tscn"), true, 2], 
	"raincloud_tiny": [preload("res://Scenes/Entities/RainCloud/raincloud_tiny.tscn"), false, 1], 
	"aqua_fish": [preload("res://Scenes/Entities/AquaFish/aqua_fish.tscn"), false, 1], 
	"metal_spawn": [preload("res://Scenes/Entities/MetalSpawn/metal_spawn.tscn"), true, 10], 
	"ambient_bird": [preload("res://Scenes/Entities/AmbientEnts/bird.tscn"), true, 24], 
	"void_portal": [preload("res://Scenes/Entities/VoidPortal/void_portal.tscn"), true, 2], 
	
	
	"picnic": [preload("res://Scenes/Entities/Props/prop_picnic.tscn"), false, 1], 
	"canvas": [preload("res://Scenes/Entities/Props/prop_canvas.tscn"), false, 1], 
	"bush": [preload("res://Scenes/Entities/Props/prop_bush.tscn"), false, 1], 
	"rock": [preload("res://Scenes/Entities/Props/prop_rock.tscn"), false, 1], 
	"fish_trap": [preload("res://Scenes/Entities/Props/prop_fish_trap.tscn"), false, 1], 
	"fish_trap_ocean": [preload("res://Scenes/Entities/Props/prop_fish_trap_ocean.tscn"), false, 1], 
	"island_tiny": [preload("res://Scenes/Entities/Props/prop_island_tiny_spawn.tscn"), false, 1], 
	"island_med": [preload("res://Scenes/Entities/Props/prop_island_med_spawn.tscn"), false, 1], 
	"island_big": [preload("res://Scenes/Entities/Props/prop_island_big_spawn.tscn"), false, 1], 
	"boombox": [preload("res://Scenes/Entities/Props/prop_boombox.tscn"), false, 1], 
	"well": [preload("res://Scenes/Entities/Props/prop_well.tscn"), false, 1], 
	"campfire": [preload("res://Scenes/Entities/Props/prop_campfire.tscn"), false, 1], 
	"chair": [preload("res://Scenes/Entities/Props/prop_chair.tscn"), false, 4], 
	"table": [preload("res://Scenes/Entities/Props/prop_table.tscn"), false, 1], 
	"therapist_chair": [preload("res://Scenes/Entities/Props/prop_therapist_chair.tscn"), false, 1], 
	"toilet": [preload("res://Scenes/Entities/Props/prop_toilet.tscn"), false, 1], 
	"whoopie": [preload("res://Scenes/Entities/Props/prop_whoopie.tscn"), false, 1], 
	"beer": [preload("res://Scenes/Entities/Props/prop_beer.tscn"), false, 1], 
	"greenscreen": [preload("res://Scenes/Entities/Props/prop_greenscreen.tscn"), false, 1], 
	"portable_bait": [preload("res://Scenes/Entities/Props/prop_portable_bait.tscn"), false, 1], 
}

@export var backdrop = false

var active_zone = ""
var active_zone_owner = - 1
var tent_info = {}
var rain_chance = 0.0
var alien_cooldown = 6

var ambient_sound_blacklist = ""
var ambient_sound_cooldown = 5

@onready var entities = $SubViewport / main / entities
@onready var map = $SubViewport / main / map / main_map
@onready var ent_timer = $SubViewport / main / ent_spawner
@onready var shader_ignore = $shader_ignore / SubViewport
@onready var shader_ignore_cam = $shader_ignore / SubViewport / Camera3D

signal _zone_change(zone)

func _ready():
	PlayerData.connect("_hide_hud_toggle", Callable(self, "_hide_hud_toggle"))
	PlayerData.emit_signal("_hide_hud_toggle", false)
	
	if not backdrop:
		Network.connect("_instance_actor", Callable(self, "_instance_actor"))
		PlayerData.connect("_request_arena_start", Callable(self, "_arena_start"))
		PlayerData.connect("_arena_join", Callable(self, "_arena_join"))
		PlayerData.connect("_arena_death", Callable(self, "_arena_death"))
		
		Network._request_actors()
		Network._update_chat("Welcome to GLOBAL chat!")
		Network._update_chat("Welcome to LOCAL chat!", true)
		
		var cosmetics = {"cosmetic_data": PlayerData.cosmetics_equipped.duplicate()}
		var spawn_pos = map.spawn_position.global_transform.origin
		var zone = "main_zone"
		
		if not PlayerData.saved_tags.has("first_join") and PlayerData.FORCE_TUTORIAL:
			PlayerData._add_saved_tag("first_join")
			zone = "tutorial_zone"
			spawn_pos = map.tutorial_spawn_position.global_transform.origin
		
		Network._sync_create_actor("player", spawn_pos, zone, - 1, Network.STEAM_ID)
		
		var aqua_data = {"fish_data": PlayerData.saved_aqua_fish.duplicate()}
		var loc = get_tree().get_nodes_in_group("aqua_spawn_loc")[0].global_transform.origin
		Network._sync_create_actor("aqua_fish", loc, "aquarium_zone", - 1, Network.STEAM_ID)
		
		_enter_zone(zone)
		rain_chance = randf_range(0.0, 0.02)
		
		Network._send_P2P_Packet({"type": "new_player_join"}, "peers", 2)
		
		if Network.GAME_MASTER:
			randomize()
			for i in 4: _spawn_metal_spot()
			
			if not Network.PLAYING_OFFLINE:
				_on_lobby_value_update_timeout()
		
		GlobalAudio._play_music("")
		ambient_sound_cooldown = randi() % 40 + 60
		
	else:
		GlobalAudio._play_music("music1_loop", 2.0)
		$SubViewport / main / track_camera / Camera3D.current = true
	
	get_tree().get_root().connect("size_changed", Callable(self, "_viewport_update"))
	call_deferred("_viewport_update")
	
	
	var res = preload("res://Assets/Models/mmtree.tres")
	res.surface_set_material(0, preload("res://Assets/Materials/dark_brown.tres"))
	res.surface_set_material(1, preload("res://Assets/Materials/green_c.tres"))
	res.surface_set_material(2, preload("res://Assets/Materials/green_c.tres"))

func _on_lobby_value_update_timeout():
	Network._set_server_browser_value()
	
	if Network.GAME_MASTER and Network.WEB_LOBBY_JOIN_QUEUE.size() > 0:
		if Network.WEB_LOBBY_JOIN_QUEUE.size() > 1:
			PlayerData._send_notification("There are " + str(Network.WEB_LOBBY_JOIN_QUEUE.size()) + " players requesting to join your game... ")
		else:
			PlayerData._send_notification("There is " + str(Network.WEB_LOBBY_JOIN_QUEUE.size()) + " player requesting to join your game... ")

func _viewport_update():
	var window_size = get_window().size
	$SubViewport.size = (window_size / Globals.pixelize_amount).ceil()

func _instance_actor(dict, network_sender = - 1):
	if not Network._validate_packet_information(dict, ["actor_type", "at", "zone", "actor_id", "creator_id", "rot", "zone_owner"], [TYPE_STRING, TYPE_VECTOR3, TYPE_STRING, TYPE_INT, TYPE_INT, TYPE_VECTOR3, TYPE_INT]):
		print("INVALID ACTOR DATA")
		return
	
	var actor_type = dict["actor_type"]
	var pos = dict["at"]
	var rot = dict["rot"]
	var zone = dict["zone"]
	var zone_owner = dict["zone_owner"]
	var actor_id = dict["actor_id"]
	var owner_id = dict["creator_id"] if network_sender == - 1 else network_sender
	
	if not ACTOR_BANK.keys().has(actor_type): return
	
	var BANK_DATA = ACTOR_BANK[actor_type]
	var host_only = BANK_DATA[1]
	var max_allowed = BANK_DATA[2]
	
	
	
	if network_sender != - 1 and Network.STEAM_LOBBY_ID > 0:
		if host_only and Steam.getLobbyOwner(Network.STEAM_LOBBY_ID) != network_sender:
			print("Actor Instance Canceled, trying to spawn host-only actor as non-host.")
			return
		
		var count = 0
		for actor in get_tree().get_nodes_in_group("actor"):
			if actor.owner_id == network_sender and actor.actor_type == actor_type:
				count += 1
		if count > max_allowed:
			print("Actor Instance Canceled, too many active of type for owner id.")
			return
	
	var actor = BANK_DATA[0].instantiate()
	actor.visible = false
	actor.global_transform.origin = pos
	actor.rotation = rot
	actor.actor_id = actor_id
	actor.owner_id = owner_id
	actor.current_zone = zone
	actor.current_zone_owner = zone_owner
	actor.actor_type = actor_type
	actor.world = self
	
	entities.add_child(actor)
	actor.global_transform.origin = pos
	
	print("created actor, ", actor_type, " w owner id ", owner_id)
	if owner_id == Network.STEAM_ID:
		Network.OWNED_ACTORS.append(actor)
		actor.add_to_group("owned_actor")

func _enter_zone(zone_id, zone_owner = - 1):
	var previous_zone = active_zone
	var previous_id = active_zone_owner
	
	
	map._get_zone("island_tiny_zone")._zone_update(zone_owner, previous_zone, previous_id)
	map._get_zone("island_med_zone")._zone_update(zone_owner, previous_zone, previous_id)
	map._get_zone("island_big_zone")._zone_update(zone_owner, previous_zone, previous_id)
	
	active_zone = zone_id
	active_zone_owner = zone_owner
	map._set_zone(zone_id)
	emit_signal("_zone_change", zone_id)
	
	if map._get_zone(zone_id).music != "": GlobalAudio._play_music(map._get_zone(zone_id).music)
	if map._get_zone(zone_id).intro_text != "": Network._update_chat(map._get_zone(zone_id).intro_text)

func _get_actor_by_id(id):
	for actor in get_tree().get_nodes_in_group("actor"):
		if actor.actor_id == id:
			return actor
	return null






func _host_spawn_object():
	var amt = 0
	var types = []
	for actor in get_tree().get_nodes_in_group("actor"):
		if actor.owner_id == Network.STEAM_ID:
			amt += 1
			types.append(actor.actor_type)
	
	if not Network.GAME_MASTER and not Network.PLAYING_OFFLINE:
		return
	
	
	
	Network.KNOWN_GAME_MASTER = Steam.getLobbyOwner(Network.STEAM_LOBBY_ID)
	
	var type = ["fish", "none"][randi() % 2]
	
	
	alien_cooldown -= 1
	if randf() < 0.01 and randf() < 0.4 and get_tree().get_nodes_in_group("meteor").size() < 1 and alien_cooldown <= 0:
		alien_cooldown = 16
		type = "fish_alien"
	
	
	if randf() < rain_chance and randf() < 0.12:
		type = "raincloud"
		rain_chance = 0.0
	else:
		if randf() < 0.75: rain_chance += 0.001
	
	
	if randf() < 0.01 and randf() < 0.25:
		type = "void_portal"
	
	match type:
		"fish": _spawn_fish()
		"fish_alien": _spawn_fish("fish_spawn_alien")
		
		"raincloud": _spawn_raincloud()
		
		"void_portal": _spawn_void_portal()
		
		"none": return


func _spawn_fish(type = "fish_spawn"):
	var point = get_tree().get_nodes_in_group("fish_spawn")[randi() % get_tree().get_nodes_in_group("fish_spawn").size()]
	var zone = "main_zone"
	
	var pos = point.global_transform.origin
	Network._sync_create_actor(type, pos, zone, - 1, Network.STEAM_ID)


func _spawn_raincloud():
	if not Network.GAME_MASTER and not Network.PLAYING_OFFLINE:
		return
	
	print("Trying to spawn cloud...")
	if get_tree().get_nodes_in_group("raincloud").size() > 0:
		print("FAILED! LOL")
		return
	var zone = "main_zone"
	
	var pos = Vector3(randf_range( - 100, 150), 42, randf_range( - 150, 100))
	Network._sync_create_actor("raincloud", pos, zone, - 1, Network.STEAM_ID)


func _spawn_metal_spot():
	if not Network.GAME_MASTER and not Network.PLAYING_OFFLINE:
		return
	
	print("Trying to spawn metal spot...")
	if get_tree().get_nodes_in_group("metal_spawn").size() > 7:
		print("FAILED! LOL")
		return
	
	var zone = "main_zone"
	var point = get_tree().get_nodes_in_group("trash_point")[randi() % get_tree().get_nodes_in_group("trash_point").size()]
	if randf() < 0.15:
		point = get_tree().get_nodes_in_group("shoreline_point")[randi() % get_tree().get_nodes_in_group("shoreline_point").size()]
	
	var pos = point.global_transform.origin + Vector3(randf_range( - 0.5, 0.5), 0.0, randf_range( - 0.5, 0.5))
	Network._sync_create_actor("metal_spawn", pos, zone, - 1, Network.STEAM_ID)

func _spawn_void_portal():
	if not Network.GAME_MASTER and not Network.PLAYING_OFFLINE:
		return
	
	print("Trying to spawn ??? portal...")
	if get_tree().get_nodes_in_group("void_portal").size() >= 1:
		print("FAILED! LOL")
		return
	
	var zone = "main_zone"
	var point = get_tree().get_nodes_in_group("hidden_spot")[randi() % get_tree().get_nodes_in_group("hidden_spot").size()]
	
	var pos = point.global_transform.origin + Vector3(randf_range( - 0.5, 0.5), 0.0, randf_range( - 0.5, 0.5))
	Network._sync_create_actor("void_portal", pos, zone, - 1, Network.STEAM_ID)

















func _import_child(child):
	child.get_parent().call_deferred("remove_child", child)
	await child.tree_exited
	shader_ignore.add_child(child)

func _hide_hud_toggle(on):
	$shader_ignore.visible = not on

func _process(delta):
	var cam = $SubViewport.get_camera_3d()
	shader_ignore_cam.transform = cam.transform




func _on_ambient_spawn_timer_timeout():
	if not Network.GAME_MASTER and not Network.PLAYING_OFFLINE:
		print("Cannot Spawn Ambient Object: Not Game Master")
		return
	
	var type = ["none", "none", "bird"][randi() % 3]
	
	match type:
		"bird": _spawn_bird()

func _spawn_bird():
	if get_tree().get_nodes_in_group("bird").size() > 8: return
	
	var count = randi() % 3 + 1
	
	var zone = "main_zone"
	var point = get_tree().get_nodes_in_group("trash_point")[randi() % get_tree().get_nodes_in_group("trash_point").size()]
	
	print("bird up")
	for i in count:
		var pos = point.global_transform.origin + Vector3(randf_range( - 2.5, 2.5), 0.0, randf_range( - 2.5, 2.5))
		Network._sync_create_actor("ambient_bird", pos, zone, - 1, Network.STEAM_ID)





func _on_host_check_timer_timeout():
	if backdrop: return
	if not Network.PLAYING_OFFLINE and not Network.GAME_MASTER:
		var found_host = false
		for member in Network.LOBBY_MEMBERS:
			if member.steam_id == Network.KNOWN_GAME_MASTER:
				found_host = true
		
		if not found_host:
			PopupMessage._show_popup("Lost connection to Host.")
			Globals._exit_game()

func _on_ping_update_timeout():
	if backdrop or Network.PLAYING_OFFLINE: return
	
	Network.emit_signal("_members_updated")
	Network._replication_check()
	
	for member in Network.LOBBY_MEMBERS:
		var connection_data = Steam.getSessionConnectionInfo(member["steam_id"], true, true)
		var ping = connection_data["ping"]
		Network.PING_DICTIONARY[member["steam_id"]] = floor(ping)
	
	if Network.GAME_MASTER:
		Steam.setLobbyData(Network.STEAM_LOBBY_ID, "code", str(Network.LOBBY_CODE))
		Steam.setLobbyData(Network.STEAM_LOBBY_ID, "count", str(Network.WEB_LOBBY_MEMBERS.size()))

func _on_time_update_timeout():
	if not Network.PLAYING_OFFLINE and Network.STEAM_LOBBY_ID > 0 and Steam.getLobbyOwner(Network.STEAM_LOBBY_ID) == Network.STEAM_ID:
		Steam.setLobbyData(Network.STEAM_LOBBY_ID, "timestamp", str(ceil(Time.get_unix_time_from_system())))





func _on_music_check_timeout():
	if backdrop: return
	
	if GlobalAudio._is_song_playing():
		return
	
	if ambient_sound_cooldown > 0:
		ambient_sound_cooldown -= 1
		if PlayerData.punching_alot: ambient_sound_cooldown -= 15
		return
	
	if randf() < 0.15 or PlayerData.punching_alot:
		var tracks = ["music1", "music2", "music3"]
		if randf() < 0.2:
			tracks = ["floombo_fuibi", "floombo_peinos", "floombo_together"]
		
		var track = tracks[randi() % tracks.size()]
		while track == ambient_sound_blacklist:
			track = tracks[randi() % tracks.size()]
		
		if PlayerData.punching_alot:
			track = "floombo_boxingglove"
		
		GlobalAudio._play_music(track)
		ambient_sound_blacklist = track
		ambient_sound_cooldown = randi() % 80 + 100
		
		print("Song Roll Success: ", track)





func _on_autosave_timer_timeout():
	if backdrop: return
	
	print("Autosaving...")
	UserSave._quick_save()
