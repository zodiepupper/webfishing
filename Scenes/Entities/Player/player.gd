extends Actor

enum STATES{DEFAULT, BUSY, OBTAIN, EMOTING, FREECAM, FISHING_CHARGE, FISHING_CAST, FISHING, FISHING_CANCEL, FISHING_STRUGGLE, SHOVEL_CAST, SHOVEL_STRUGGLE, SHOVEL_CANCEL, \
NET_CAST, NET_STRUGGLE, NET_CANCEL, SHOWCASE, CONSUME_ITEM, METAL_DETECTOR, GUITAR, GAMBLING}

const GRAVITY = 32.0
const BAIT_DATA = {
	"": {"catch": 0.0, "max_tier": 0, "quality": []}, 
	
	"worms": {"catch": 0.06, "max_tier": 1, "quality": [1.0]}, 
	"cricket": {"catch": 0.06, "max_tier": 2, "quality": [1.0, 0.05]}, 
	"leech": {"catch": 0.06, "max_tier": 2, "quality": [1.0, 0.15, 0.05]}, 
	"minnow": {"catch": 0.06, "max_tier": 2, "quality": [1.0, 0.5, 0.25, 0.05]}, 
	"squid": {"catch": 0.06, "max_tier": 2, "quality": [1.0, 0.8, 0.45, 0.15, 0.05]}, 
	"nautilus": {"catch": 0.06, "max_tier": 2, "quality": [1.0, 0.98, 0.75, 0.55, 0.25, 0.05]}, 
	"gildedworm": {"catch": 0.06, "max_tier": 2, "quality": [1.0, 0.99, 0.85, 0.75, 0.55, 0.12]}, 
}
const PARTICLE_DATA = {
	"dust_run": preload("res://Scenes/Particles/dust_running.tscn"), 
	"dust_land": preload("res://Scenes/Particles/dust_land.tscn"), 
	"splash": preload("res://Scenes/Particles/water_splash.tscn"), 
	"small_splash": preload("res://Scenes/Particles/small_splash.tscn"), 
	"music": preload("res://Scenes/Particles/music_particle.tscn"), 
	"kiss": preload("res://Scenes/Particles/kiss.tscn"), 
}

export (NodePath) var hand_sprite_node
export (NodePath) var hand_bone_node
export var NPC_body = false
export var NPC_cosmetics = {"species": "species_cat", "pattern": "pattern_none", "primary_color": "pcolor_white", "secondary_color": "scolor_tan", "hat": "hat_none", "undershirt": "shirt_none", "overshirt": "overshirt_none", "title": "title_rank_1", "bobber": "bobber_default", "eye": "eye_halfclosed", "nose": "nose_cat", "mouth": "mouth_default", "accessory": [], "tail": "tail_cat"}
export var NPC_name = "NPC Test"
export var NPC_title = "npc title here"

var camera_zoom = 5.0

var direction = Vector3()
var gravity_vec = Vector3()
var dive_vec = Vector3()
var velocity = Vector3()
var player_scale = 1.0

var cam_orbit_node = null
var cam_follow_node = null
var cam_push = 0.0
var cam_push_cur = 0.0
var cam_return = 1.0
var force_cam_look = false
var mouse_world_pos = Vector3()
var mouse_look = false

var state = STATES.DEFAULT
var walk_speed = 3.2
var slow_walk_speed = 1.0
var sprint_speed = 6.44
var sneak_speed = 1.3
var jump_height = 6.0
var jump_leap = 0.0
var dive_distance = 9.0
var accel = 64.0
var sprinting = false
var slow_walking = false
var sneaking = false
var diving = false
var request_jump = false
var ignore_snap = 0
var snapped = false
var sitting = false
var locked = false
var interact_prevention = false
var busy = false
var in_air = false
var gravity_disable = false
var hud
var int_text = ""
var interact_cooldown = 60
var xp_buildup = 0
var showcase_ref

var held_item = PlayerData.FALLBACK_ITEM
var caught_item = PlayerData.FALLBACK_ITEM
var held_item_weight = 1.0
var previous_item = 0
var primary_hold_timer = 0
var fish_zone_data = {}
var rod_cast_data = ""
var casted_bait = ""
var rod_cast_dist = 0.0
var rod_depth = 0
var failed_casts = 0
var recent_reel = 0.0
var item_scene = null
var bobber_hpos = Vector3()
var bobber_vpos = 0
var bobber_control = true
var last_valid_pos = Vector3()
var retract_splash = false
var show_local = false
var bait_warn = 2
var in_rain = false
var consume_on_state_change = - 1
var item_cooldown = 0
var punch_count = 0
var emote_timescale = 1.0

var rod_damage = 1.0
var rod_spd = 1.0
var rod_chance = 0.0




var boost_timer = 0
var boost_amt = 1.3
var boost_mult = 1.0
var catch_drink_timer = 0
var catch_drink_boost = 1.0
var catch_drink_reel = 1.0
var catch_drink_xp = 1.0
var catch_drink_gold_add = Vector2(0, 0)
var catch_drink_gold_percent = 0.0
var catch_drink_tier = 0
var drunk_timer = 0
var drunk_tier = 0
var drunk_wander_length = 0
var drunk_wander_dir = 0
var jump_bonus = 1.0
var dive_bonus = 1.0
var jump_bonus_timer = 0
var jump_bonus_tier = 0

var death_counter = 0
var metal_detect_flop = false
var metal_detect_alert_level = 0
var metal_detect_alert_cd = 0

var emoting = false
var emote_full = false
var emote_locked = false
var emote_looping = false
var animation_timer = 0
var animation_goal = 99
var buffer_state = - 1
var animation_data = {
	"bobber_position": Vector3(), 
	"diving": false, 
	"sitting": false, 
	"alert": false, 
	"busy": false, 
	"emote": "", 
	"caught_item": {}, 
	"moving": 0, 
	"emote_state": 0, 
	"arm_value": 0.0, 
	"item_bend": 0.0, 
	"land": 0.0, 
	"talking": 0.0, 
	"recent_reel": 0.0, 
	"player_scale": 1.0, 
	"move_timescale": 1.0, 
	"back_bend": 0.0, 
	"drunk_tier": 0, 
	"state": state, 
	"wagging": false, 
	"mushroom": false, 
	"dive_scrape": false, 
	"reel_slow": false, 
	"reel_fast": false, 
}
var shared_animation_data: Array = []
var custom_held_item = ""

var cosmetic_data = {}
var known_cosmetic_data = {}
var selected_build_object
var old_rot = Vector3()
var rot_diff = 0.0

var prop_ids = []
var cam_move = false
var freecamming = false

onready var cam_base = $cam_base
onready var cam_pivot = $cam_base / cam_pivot
onready var camera = $Camera
onready var camera_point = $cam_base / cam_pivot / SpringArm / camera_point
onready var cam_arm = $cam_base / cam_pivot / SpringArm
onready var body = $body
onready var body_mesh = $body / player_body / Armature / Skeleton / body_main
onready var rot_help = $rot_help
onready var interact_range = $interact_range
onready var anim_tree = $body / AnimationTree
onready var skeleton = $body / player_body / Armature / Skeleton
onready var title = $Viewport / player_label
onready var item_sprite = get_node(hand_sprite_node)
onready var hand_bone = get_node(hand_bone_node)
onready var sound_emit = $sound_emit
onready var face = $body / player_body / Armature / Skeleton / face / player_face
onready var tail = $body / player_body / Armature / Skeleton / tail / holder / tail
onready var freecam_anchor = $camera_freecam_anchor
onready var sound_manager = $sound_manager

onready var fish_detect = $detection_zones / fishing_detect
onready var fishing_update = $detection_zones / fishing_update
onready var fishing_area = $detection_zones / fishing_detect / fishing_area
onready var fish_timer = $fish_catch_timer
onready var bobber_preview = $bobber_preview
onready var bobber = $bobber
onready var bobber_mesh = $bobber / bobber_mesh
onready var bobber_line = $bobber / line
onready var ripples = $bobber / ripples
onready var caught_fish = $bobber / caught_item

onready var shovel_area = $detection_zones / shovel_detect
onready var net_area = $detection_zones / net_detect

onready var safe_check = $safe_check

onready var lvlparticle = $emotion_particles / lvl_particles
onready var lvlparticleb = $emotion_particles / lvl_particles2

signal _animation_finished
signal _primary_release
signal _state_change
signal _menu_closed





func _ready():
	custom_valid_actions = [
		"_update_cosmetics", 
		"_sync_level_bubble", 
		"_update_held_item", 
		"_sync_sound", 
		"_sync_create_bubble", 
		"_talk", 
		"_face_emote", 
		"_play_particle", 
		"_play_sfx", 
		"_sync_strum", 
		"_sync_hammer", 
		"_sync_punch"
	]
	
	add_to_group("player")
	rot_help.set_as_toplevel(true)
	cam_base.set_as_toplevel(true)
	camera.set_as_toplevel(true)
	freecam_anchor.set_as_toplevel(true)
	anim_tree.tree_root = anim_tree.tree_root.duplicate(true)
	_update_cosmetics(cosmetic_data)
	title.visible = not dead_actor
	
	if NPC_body:
		camera.queue_free()
		remove_from_group("player")
		
		yield(get_tree(), "idle_frame")
		var new = NPC_cosmetics
		Network._send_actor_action(actor_id, "_update_cosmetics", [new])
		_update_cosmetics(new)
		
		yield(get_tree(), "idle_frame")
		title.visible = true
		title.label = NPC_name
		title.title = NPC_title

func _setup_controlled():
	if NPC_body: return
	
	add_to_group("controlled_player")
	camera = $Camera
	camera.current = true
	hud = load("res://Scenes/HUD/playerhud.tscn").instance()
	hud.player = self
	hud.connect("_player_sit", self, "_toggle_sit")
	hud.connect("_play_emote", self, "_play_emote")
	hud.connect("_menu_entered", self, "_hud_menu_entered")
	hud.connect("_message_sent", self, "_message_sent")
	hud.connect("_freecam_toggle", self, "_toggle_freecam")
	get_tree().get_root().add_child(hud)
	
	PlayerData.connect("_clear_all_props", self, "_clear_all_props")
	PlayerData.connect("_place_prop", self, "_create_prop")
	PlayerData.connect("_play_sfx", self, "_play_sfx")
	PlayerData.connect("_play_guitar", self, "_strum_guitar")
	PlayerData.connect("_hammer_guitar", self, "_hammer_string")
	PlayerData.connect("_return_to_spawn", self, "_return_to_spawn")
	PlayerData.connect("_punched", self, "_punched")
	PlayerData.connect("_item_removal", self, "_item_removal")
	PlayerData.connect("_update_props", self, "_refresh_props")
	var delayed_update = get_tree().create_timer(1.0).connect("timeout", self, "_change_cosmetics")
	
	PlayerData.connect("_wag_toggle", self, "_wag")
	PlayerData.connect("_kiss", self, "_kiss")
	
	Network.connect("_user_connected", self, "_refresh_cosmetics")
	Network.connect("_network_tick", self, "_share_animation_data")

func _setup_not_controlled():
	camera = $Camera
	camera.queue_free()
	
	$bobber_preview.visible = false
	$local_range.visible = false
	$detection_zones / metal_detect_consume.monitoring = false
	$detection_zones / metal_detect_consume.monitorable = false
	
	
	$detection_zones / prop_detect.monitoring = false
	$detection_zones / metal_detect_far.monitoring = false
	$detection_zones / metal_detect.monitoring = false
	$detection_zones / metal_detect_close.monitoring = false
	$detection_zones / metal_detect_veryclose.monitoring = false
	$detection_zones / punch.monitoring = false
	$interact_range.monitoring = false
	$water_detect.monitoring = false
	$raincloud_check.monitoring = false





func _physics_process(delta):
	_process_animation()
	_process_sounds()
	
	if ( not in_zone != $CollisionShape.disabled):
		$CollisionShape.disabled = not in_zone

func _process(delta):
	if controlled: $paint_node._paint_process(delta)

func _controlled_process(delta):
	_get_input()
	_process_movement(delta)
	_process_timers()
	_interact_check()
	_update_animation_data()
	_camera_update()
	
	_freecam_input(delta)
	
	current_zone = world.active_zone
	current_zone_owner = world.active_zone_owner
	
	fish_detect.translation.z = - rod_cast_dist
	bobber_preview.translation.z = - clamp(primary_hold_timer * 0.06, 1.5, 9.0)
	if bobber_preview.is_colliding(): $"%bobber_prev_mesh".global_transform.origin = bobber_preview.get_collision_point() + Vector3(0, 0.05, 0)
	bobber_preview.visible = state == STATES.FISHING_CHARGE
	
	if recent_reel > 0: recent_reel -= 1
	if interact_cooldown > 0: interact_cooldown -= 1
	
	animation_data["reel_slow"] = recent_reel > 8
	animation_data["reel_fast"] = state == STATES.FISHING_STRUGGLE
	
	Network.MESSAGE_ORIGIN = global_transform.origin
	$local_range.visible = show_local
	
	$paint_node.global_transform.origin = mouse_world_pos
	$metaldetect_dot.modulate.a = lerp($metaldetect_dot.modulate.a, 0.0, 0.1)


func _camera_update():
	var cam_push_dest = cam_push * rod_cast_dist if camera_zoom > 0.5 else 0.0
	cam_push_cur = lerp(cam_push_cur, cam_push_dest, 0.2)
	var push = global_transform.basis.z * cam_push_cur
	camera_zoom = clamp(camera_zoom, 0.0, 20.0)
	
	var cam_zoom = camera_zoom
	var cam_zoom_lerp = 0.4
	var cam_follow_point = true
	var cam_follow_pos = Vector3()
	var cam_follow_rot = Vector3()
	var sit_add = Vector3(0, - 0.2, 0.0) if sitting else Vector3.ZERO
	var cam_base_pos = global_transform.origin + push + sit_add
	
	var desired_fov = 50
	if sprinting and direction != Vector3.ZERO:
		desired_fov += 2
		if boost_timer > 0: desired_fov += 2 * boost_amt
	if animation_data["mushroom"]: desired_fov += 10
	
	camera.fov = lerp(camera.fov, desired_fov, 0.2)
	
	if is_instance_valid(cam_orbit_node) and cam_orbit_node.is_visible_in_tree():
		cam_base_pos = cam_orbit_node.global_transform.origin
	
	if is_instance_valid(cam_follow_node) and cam_follow_node.is_visible_in_tree():
		cam_follow_point = false
		cam_follow_pos = cam_follow_node.global_transform.origin
		cam_follow_rot = cam_follow_node.global_rotation
		_zoom_update()
	
	var cam_speed = 0.08
	if cam_follow_point:
		cam_return = lerp(cam_return, 1.0, cam_speed * 0.5)
		camera.global_transform.origin = lerp(camera.global_transform.origin, camera_point.global_transform.origin, cam_return)
		camera.rotation.x = lerp_angle(camera.rotation.x, camera_point.global_rotation.x, cam_return)
		camera.rotation.y = lerp_angle(camera.rotation.y, camera_point.global_rotation.y, cam_return)
		camera.rotation.z = lerp_angle(camera.rotation.z, camera_point.global_rotation.z, cam_return)
	else:
		cam_return = 0.0
		camera.global_transform.origin = lerp(camera.global_transform.origin, cam_follow_pos, cam_speed)
		camera.rotation.x = lerp_angle(camera.rotation.x, cam_follow_rot.x, cam_speed)
		camera.rotation.y = lerp_angle(camera.rotation.y, cam_follow_rot.y, cam_speed)
		camera.rotation.z = lerp_angle(camera.rotation.z, cam_follow_rot.z, cam_speed)
	
	cam_base.global_transform.origin = cam_base_pos
	cam_arm.spring_length = lerp(cam_arm.spring_length, cam_zoom, cam_zoom_lerp)

func _zoom_update():
	var v = camera_zoom > 0.5 or is_instance_valid(cam_follow_node) or freecamming
	if body.visible != v: body.visible = v

func _interact_check():
	if not controlled: return
	var in_range = false
	
	if not interact_prevention:
		for area in interact_range.get_overlapping_areas():
			if area.is_in_group("interactable") and area.is_visible_in_tree():
				int_text = area.text
				in_range = true
				break
	if hud:
		hud.interact = in_range
		hud.int_text = int_text

func _hud_menu_entered(menu):
	if menu == 0:
		if not freecamming:
			cam_orbit_node = null
		cam_follow_node = null
		force_cam_look = false
		_exit_showcase()
		_zoom_update()
		emit_signal("_menu_closed")

func _process_timers():
	if catch_drink_timer > 0:
		catch_drink_timer -= 1
		if catch_drink_timer <= 0:
			catch_drink_boost = 1.0
			catch_drink_reel = 1.0
			catch_drink_xp = 1.0
			catch_drink_gold_add = Vector2(0, 0)
			catch_drink_gold_percent = 0.0
	
	drunk_tier = 0
	if drunk_timer > 0:
		drunk_timer -= 1
		if drunk_timer >= 50000: drunk_tier = 4
		elif drunk_timer >= 19000: drunk_tier = 3
		elif drunk_timer >= 10000: drunk_tier = 2
		elif drunk_timer > 0: drunk_tier = 1
		else: drunk_tier = 0
	
	if jump_bonus_timer > 0:
		jump_bonus_timer -= 1
		if jump_bonus_timer <= 0:
			jump_bonus_tier = 0
			jump_bonus = 1.0
			dive_bonus = 1.0
	
	if item_cooldown > 0: item_cooldown -= 1





func _get_input():
	direction = Vector3.ZERO
	
	if Input.is_action_just_released("primary_action"): _primary_action_release()
	if Input.is_action_pressed("primary_action"): _primary_action_hold()
	else: primary_hold_timer = 0
	
	if busy:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		return
	
	if Input.is_action_pressed("secondary_action") or camera_zoom <= 0.0:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			PlayerData.original_mouse_position = get_tree().get_nodes_in_group("world_viewport")[0].get_mouse_position()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		if Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			Input.warp_mouse_position(PlayerData.original_mouse_position)
	
	if Input.is_action_just_released("zoom_in"):
		camera_zoom -= 0.5
		_zoom_update()
	if Input.is_action_just_released("zoom_out"):
		camera_zoom += 0.5
		_zoom_update()
	
	if Input.is_action_just_pressed("interact"): _interact()
	
	if Input.is_action_just_pressed("bind_1"): _equip_hotbar(0)
	if Input.is_action_just_pressed("bind_2"): _equip_hotbar(1)
	if Input.is_action_just_pressed("bind_3"): _equip_hotbar(2)
	if Input.is_action_just_pressed("bind_4"): _equip_hotbar(3)
	if Input.is_action_just_pressed("bind_5"): _equip_hotbar(4)
	
	if Input.is_action_just_pressed("bark"):
		_bark()
	if Input.is_action_just_pressed("kiss"):
		_kiss()
	
	if locked: return
	
	
	if is_instance_valid(camera):
		var camera_cam = camera
		var ray_length = 1000
		var mouse_pos = get_tree().get_nodes_in_group("world_viewport")[0].get_mouse_position() / Globals.pixelize_amount
		var from = camera_cam.project_ray_origin(mouse_pos)
		var to = from + camera_cam.project_ray_normal(mouse_pos) * ray_length
		var space_state = get_world().get_direct_space_state()
		var result = space_state.intersect_ray(from, to, [])
		if result.has("position"):
			mouse_world_pos = result["position"]
			mouse_world_pos.y = global_transform.origin.y
	
	if freecamming: return
	if Input.is_action_just_pressed("move_jump"): request_jump = true
	
	mouse_look = false
	
	if sitting: return
	
	if Input.is_action_pressed("move_forward"): direction -= cam_base.transform.basis.z
	if Input.is_action_pressed("move_back"): direction += cam_base.transform.basis.z
	if Input.is_action_pressed("move_right"): direction += cam_base.transform.basis.x
	if Input.is_action_pressed("move_left"): direction -= cam_base.transform.basis.x
	
	if drunk_wander_length > 0:
		direction += drunk_wander_dir
		drunk_wander_length -= 1
	
	mouse_look = Input.is_action_pressed("mouse_look")
	
	if OptionsMenu.sprint_toggle:
		if Input.is_action_just_pressed("move_sprint"):
			OptionsMenu.sprint_toggle_active = not OptionsMenu.sprint_toggle_active
			if OptionsMenu.sprint_toggle_active: PlayerData._send_notification("toggled sprint on")
			else: PlayerData._send_notification("toggled sprint off")
	else: OptionsMenu.sprint_toggle_active = false
	var requesting_sprint = OptionsMenu.sprint_toggle_active or Input.is_action_pressed("move_sprint")
	
	sprinting = not Input.is_action_pressed("move_sneak") and requesting_sprint
	sneaking = Input.is_action_pressed("move_sneak") and not Input.is_action_pressed("move_sprint")
	slow_walking = Input.is_action_pressed("move_walk")
	
	if emote_locked:
		request_jump = false
		direction = Vector3.ZERO

func _input(event):
	if not controlled: return
	
	var mouse_sens = OptionsMenu.mouse_sens
	var invert = Vector2(1, 1)
	if OptionsMenu.mouse_invert == 1: invert.x = - 1
	elif OptionsMenu.mouse_invert == 2: invert.y = - 1
	elif OptionsMenu.mouse_invert == 3: invert = Vector2( - 1, - 1)
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		cam_base.rotation_degrees.y -= event.relative.x * mouse_sens * invert.x
		cam_pivot.rotation_degrees.x -= event.relative.y * mouse_sens * invert.y
		cam_pivot.rotation_degrees.x = clamp(cam_pivot.rotation_degrees.x, - 80, 80)

func _unhandled_input(event):
	if not controlled: return
	
	if event.is_action_pressed("primary_action"): _primary_action()




func _process_movement(delta):
	var snap_vec = Vector3(0, - 0.4, 0)
	var y_slow = 0.02
	
	if is_on_floor() and in_air:
		if gravity_vec.y <= - 12.0 and not diving and jump_bonus <= 1.0:
			diving = true
			dive_vec = gravity_vec.length() * - transform.basis.z * 0.2
		in_air = false
		_sync_particle("dust_land", Vector3(0, - 1, 0))
		_sync_sfx("land")
		animation_data["land"] = 0.3
	elif gravity_vec.y < - 6.0:
		in_air = true
	
	if is_on_floor() and ignore_snap <= 0:
		y_slow = 0.2
		gravity_vec = get_floor_normal() * - 1.0
		snapped = true
	elif snapped and ignore_snap <= 0:
		gravity_vec = Vector3.ZERO
		snapped = false
	else:
		snap_vec = Vector3.ZERO
		var grav = GRAVITY * Vector3.DOWN * delta
		gravity_vec += grav
	
	if request_jump:
		request_jump = false
		snap_vec = Vector3.ZERO
		if is_on_floor():
			_sync_sfx("jump")
			if jump_bonus > 1.0: _sync_sfx("jump_big")
			snapped = false
			diving = false
			gravity_vec = Vector3(0, jump_height * jump_bonus, 0)
			if sprinting and jump_leap > 0.0:
				gravity_vec += - transform.basis.z.normalized() * jump_leap
		elif not diving:
			_sync_sfx("dive_woosh")
			snapped = false
			diving = true
			dive_vec = - transform.basis.z.normalized() * dive_distance * dive_bonus
			dive_vec.y = 0
			gravity_vec += Vector3(0, jump_height * 0.5 * dive_bonus, 0)
		_toggle_sit(true)
	
	if ignore_snap > 0:
		snap_vec = Vector3.ZERO
		ignore_snap -= 1
		snapped = false
	
	boost_mult = 1.0
	if boost_timer > 0:
		boost_timer -= 1
		boost_mult = boost_amt
	
	var _speed = walk_speed
	if sprinting: _speed = sprint_speed * boost_mult
	elif sneaking: _speed = sneak_speed
	elif slow_walking: _speed = slow_walk_speed
	var _accel = accel if is_on_floor() else accel * 0.35
	
	var speed_mult = 1.0
	
	
	speed_mult = clamp(speed_mult - ((held_item_weight / 25.0) * 0.05), 0.15, 1.0)
	
	if diving: speed_mult = 0.0
	if gravity_disable: gravity_vec = Vector3.ZERO
	
	velocity = velocity.move_toward(direction.normalized() * _speed * speed_mult, delta * _accel)
	move_and_slide_with_snap(velocity + gravity_vec + dive_vec, snap_vec, Vector3.UP)
	
	dive_vec = dive_vec.move_toward(Vector3.ZERO, delta * _accel * y_slow)
	if not diving: dive_vec = Vector3.ZERO
	
	rot_help.global_transform.origin = global_transform.origin
	
	if direction != Vector3.ZERO:
		var dir = direction
		if diving and dive_vec != Vector3.ZERO: dir = dive_vec.normalized()
		
		rot_help.look_at(cam_base.global_transform.origin + dir, Vector3.UP)
		rotation.y = lerp_angle(rotation.y, rot_help.rotation.y, 0.2)
	elif force_cam_look:
		rot_help.look_at(camera.global_transform.origin, Vector3.UP)
		rotation.y = lerp_angle(rotation.y, rot_help.rotation.y, 0.2)
	elif mouse_look and not busy:
		rot_help.look_at(mouse_world_pos, Vector3.UP)
		rot_diff = abs(rot_help.rotation.y - rotation.y)
		rotation.y = lerp_angle(rotation.y, rot_help.rotation.y, 0.2)
	
	rot_diff = lerp(rot_diff, 0.0, 0.5)
	
	if diving and dive_vec.length() > 0.4 and is_on_floor():
		
		animation_data["dive_scrape"] = true
		
		if Engine.get_idle_frames() % 4 == 0:
			_sync_particle("dust_run", Vector3(0, - 0.8, 0))
	else:
		
		animation_data["dive_scrape"] = false
	
	if gravity_vec.y < - 250:
		_kill()




func _enter_state(new_state):
	if new_state == - 1: return
	
	if consume_on_state_change != - 1:
		PlayerData._remove_item(consume_on_state_change, false)
		consume_on_state_change = - 1
	
	state = new_state
	emit_signal("_state_change")
	cam_push = 0.0
	interact_prevention = false
	
	match state:
		STATES.DEFAULT:
			animation_data["item_bend"] = 0.0
			locked = false
		STATES.BUSY: locked = false
		STATES.OBTAIN: locked = true
		STATES.SHOWCASE:
			locked = true
			interact_prevention = true
			_equip_item(PlayerData._find_item_code(showcase_ref), true, true)
		
		STATES.FISHING:
			cam_push = - 0.3
			locked = true
			interact_prevention = true
			PlayerData.emit_signal("_help_update", "hold to reel (SPRINT reels quicker)")
			_enter_animation("rod_idle", true)
		STATES.FISHING_CANCEL:
			animation_data["item_bend"] = 0.1
			cam_push = - 0.3
			locked = true
			interact_prevention = true
			rod_cast_dist = 0.0
			PlayerData.emit_signal("_item_equip", held_item.ref)
			_bobber_retract()
			_enter_animation("rod_retract", false, true, STATES.DEFAULT)
		STATES.FISHING_CAST:
			cam_push = - 0.3
			locked = true
			interact_prevention = true
		STATES.FISHING_CHARGE:
			cam_push = 0.0
			locked = false
			interact_prevention = true
		STATES.FISHING_STRUGGLE:
			animation_data["item_bend"] = - 0.7
			cam_push = - 0.3
			locked = true
			interact_prevention = true
			_enter_animation("rod_struggle", true)
		
		STATES.GUITAR: locked = true
		
		STATES.SHOVEL_CAST: locked = true
		STATES.SHOVEL_STRUGGLE:
			locked = true
			_shovel_check()
		STATES.SHOVEL_CANCEL:
			locked = true
			_enter_animation("shovel_retract", false, true, STATES.DEFAULT)
		
		STATES.NET_CAST: locked = true
		STATES.NET_STRUGGLE:
			locked = true
			_net_check()
		STATES.NET_CANCEL:
			locked = true
			_enter_animation("net_retract", false, true, STATES.DEFAULT)
		
		STATES.CONSUME_ITEM:
			locked = false
			if not PlayerData._item_exists(held_item["ref"]): _equip_item({"ref": 0}, true, true)
			_enter_state(STATES.DEFAULT)

func _primary_action():
	match state:
		STATES.DEFAULT:
			_use_item()
		STATES.OBTAIN:
			_enter_animation("equip", false, true, 0, false)

func _primary_action_hold():
	primary_hold_timer += 1
	
	match state:
		STATES.DEFAULT:
			return
		STATES.FISHING:
			_enter_animation("rod_reel", true)
			rod_cast_dist -= 0.04 if Input.is_action_pressed("move_sprint") else 0.01
			bobber_control = true
			recent_reel = 15
			if rod_cast_dist < 1.5: _enter_state(STATES.FISHING_CANCEL)

func _primary_action_release():
	emit_signal("_primary_release")
	
	match state:
		STATES.DEFAULT:
			_release_item()
		STATES.FISHING:
			_enter_animation("rod_idle", true)
		STATES.METAL_DETECTOR:
			_enter_state(STATES.DEFAULT)





func _interact():
	if not controlled or interact_cooldown > 0 or interact_prevention: return
	
	for area in interact_range.get_overlapping_areas():
		if area.is_in_group("interactable") and area.is_visible_in_tree():
			area._activate(self)
			interact_cooldown = 60
			return

func _enter_zone(zone, entrance_id, zone_owner = - 1):
	if not controlled: return
	world._enter_zone(zone, zone_owner)
	PlayerData.player_saved_zone = zone
	PlayerData.player_saved_zone_owner = zone_owner
	
	print("Finding entrance w id: ", entrance_id, " and owner: ", zone_owner)
	for entrance in get_tree().get_nodes_in_group("area_entrance"):
		print(entrance.entrance_id, ": ", entrance.entrance_owner, " ?")
		if entrance.entrance_id == entrance_id and entrance.entrance_owner == zone_owner:
			global_transform.origin = entrance.global_transform.origin
			last_valid_pos = global_transform.origin
			return
	
	print("Fallback!")
	global_transform.origin = world.map.spawn_position.global_transform.origin
	world._enter_zone("main_zone", - 1)
	PlayerData.player_saved_zone = "main_zone"
	PlayerData.player_saved_zone_owner = - 1
	last_valid_pos = global_transform.origin

func _obtain_item(ref, bonus_text = [], journal_check = true):
	old_rot = rotation
	showcase_ref = ref
	_equip_item({"ref": - 1}, true, true)
	_enter_animation("equip", false, false, STATES.SHOWCASE, false)
	_play_sfx("strum")
	
	
	var data = PlayerData._find_item_code(ref)
	var text = "You caught a " + PlayerData._get_item_name(ref) + "! [color=#d5aa73](It's " + str(data["size"]) + "cm!)[/color]\n\n" + str(Globals.item_data[data["id"]]["file"].catch_blurb)
	
	if journal_check:
		var new = true
		for type in PlayerData.journal_logs.keys():
			for entry in PlayerData.journal_logs[type].keys():
				if entry == data.id and PlayerData.journal_logs[type][entry].count > 1:
					new = false
					break
		if new:
			text = "Woah, a new creature! " + text
	
	hud.dialogue_text = [text]
	if bonus_text != []: hud.dialogue_text.append_array(bonus_text)
	hud._change_menu(6)
	
	force_cam_look = true
	yield(get_tree().create_timer(0.1), "timeout")
	cam_follow_node = $catch_cam_position

func _level_up():
	yield(get_tree().create_timer(0.4), "timeout")
	var bubble = title._create_level_bubble()
	Network._send_actor_action(actor_id, "_sync_level_bubble", [], false)
	GlobalAudio._play_sound("jingle_win")
	
	_play_emote("emote_cheer", "happy")
	
	$emotion_particles / lvl_particles.restart()
	$emotion_particles / lvl_particles2.restart()

func _exit_showcase():
	if state != STATES.SHOWCASE: return
	_exit_animation()
	_enter_state(STATES.DEFAULT)
	_equip_item(PlayerData._find_item_code(previous_item), false)
	get_tree().create_tween().tween_property(self, "rotation", old_rot, 0.3)
	
	if xp_buildup > 0:
		PlayerData._add_xp(ceil(xp_buildup))
		xp_buildup = 0

func _equip_hotbar(slot):
	if locked or not PlayerData.hotbar.keys().has(slot): return
	var ref = PlayerData.hotbar[slot]
	_equip_item(PlayerData._find_item_code(ref))

func _equip_item(item_data, skip_anim = false, forced = false, set_prev = true):
	if set_prev and held_item["ref"] != 0: previous_item = held_item["ref"]
	if (state != STATES.DEFAULT and not forced) or held_item["ref"] == item_data["ref"]: return
	
	if not item_data.keys().has("id") or not Globals.item_data.keys().has(item_data["id"]):
		item_data = PlayerData.FALLBACK_ITEM
	
	PlayerData.emit_signal("_item_equip", item_data["ref"])
	
	if not skip_anim:
		_sync_sfx("equip")
		_enter_state(STATES.BUSY)
		_enter_animation("equip", false, false, STATES.DEFAULT, false)
		yield(self, "_animation_finished")

	
	var held_data = item_data.duplicate()
	
	hud.show_bait = Globals.item_data[item_data["id"]]["file"].show_bait
	
	var data = Globals.item_data[item_data["id"]]["file"]
	held_item_weight = item_data["size"]
	if not data.uses_size: held_item_weight = 0.0
	
	_update_held_item(held_data)
	Network._send_actor_action(actor_id, "_update_held_item", [held_item], false)

func _use_item():
	if not controlled: return
	
	if held_item.empty(): return
	var item_data = Globals.item_data[held_item["id"]]["file"]
	if has_method(item_data.action) and item_data.action != "":
		callv(item_data.action, item_data.action_params)

func _release_item():
	if held_item.empty(): return
	var item_data = Globals.item_data[held_item["id"]]["file"]
	if has_method(item_data.release_action) and item_data.release_action != "":
		call(item_data.release_action)







func _cast_fishing_rod():
	rod_cast_data = PlayerData.LURE_DATA[PlayerData.lure_selected].effect_id
	animation_data["caught_item"] = {}
	bait_warn = 1
	
	rod_damage = [1, 3, 10, 20, 35, 50, 70, 90, 125][PlayerData.rod_power_level]
	rod_spd = [0.0, 0.1, 0.24, 0.4, 0.7, 1.0][PlayerData.rod_speed_level]
	rod_chance = [0.0, 0.02, 0.04, 0.06, 0.08, 0.1][PlayerData.rod_chance_level]
	
	_enter_state(STATES.FISHING_CHARGE)
	_enter_animation("rod_wind", true, false, - 1, false)
	yield(self, "_primary_release")
	if state != STATES.FISHING_CHARGE: return
	_enter_state(STATES.FISHING_CAST)
	_sync_sfx("woosh", null, 1.0, 0.4)
	var strength = clamp(primary_hold_timer * 0.06, 1.5, 9.0)
	rod_cast_dist = strength
	fish_detect.translation.z = - strength
	
	var is_valid_fishing_spot = false
	if bobber_preview.is_colliding() and bobber_preview.get_collider().is_in_group("valid_water"):
		is_valid_fishing_spot = true
	
	_bobber_cast(rod_cast_dist, bobber_preview.get_collision_point() + Vector3(0, 0.75, 0), is_valid_fishing_spot)
	
	rod_depth = 0
	
	casted_bait = PlayerData.bait_selected
	if casted_bait != "" and PlayerData.bait_inv[casted_bait] <= 0: casted_bait = ""
	
	_exit_animation()
	if is_valid_fishing_spot:
		animation_data["item_bend"] = 0.3
		retract_splash = true
		_enter_animation("rod_cast", false, true, STATES.FISHING)
	else:
		animation_data["item_bend"] = 0.3
		retract_splash = false
		_enter_animation("rod_cast", false, true, STATES.FISHING_CANCEL)
	
	yield(get_tree().create_timer(0.4), "timeout")
	animation_data["item_bend"] = - 0.2

func _on_fish_catch_timer_timeout():
	if not controlled: return
	
	fish_timer.wait_time = rand_range(2.0, 3.0)
	fish_timer.start()
	
	if state != STATES.FISHING: return
	var fish_type = "ocean"
	var type_lock = false
	var junk_mult = 1.0
	
	
	fish_zone_data = {"id": - 1, "boost": 0.0, "quality_boost": 1.0}
	for zone in fishing_area.get_overlapping_areas():
		if zone.is_in_group("fish_zone"):
			fish_zone_data["id"] = zone.id
			fish_zone_data["boost"] = zone.chance_boost
			fish_zone_data["quality_boost"] = zone.quality_boost
			junk_mult = zone.junk_mult
			
			if zone.fish_type != "": fish_type = zone.fish_type
			
			if zone.alt_chance > 0.0 and randf() < zone.alt_chance:
				fish_type = zone.alt_type
			
			type_lock = zone.type_lock
	
	var fish_chance = 0.0
	var base_chance = BAIT_DATA[casted_bait]["catch"]
	fish_chance = base_chance
	fish_chance += (base_chance * failed_casts)
	fish_chance += (base_chance * rod_chance)
	fish_chance += fish_zone_data["boost"] * fish_chance
	if recent_reel > 0: fish_chance *= 1.1
	if rod_cast_data == "attractive": fish_chance *= 1.3
	if in_rain: fish_chance *= 1.1
	
	fish_chance *= catch_drink_boost
	print("Fish chance w ", fish_chance, "w type ", fish_type)
	
	bait_warn -= 1
	if bait_warn <= 0 and fish_chance <= 0.0:
		bait_warn = 8
		var text = ""
		if casted_bait == "":
			text = "[color=#ac0029]You've got no bait attached! You won't catch any fish like that...[/color]"
		else:
			text = "[color=#ac0029]Seems nothing is going to bite... perhaps your bait isn't for this water...[/color]"
		
		Network._update_chat(text)
	
	if randf() > fish_chance:
		failed_casts += 0.05
		return
	failed_casts = 0.0
	
	
	var bait_use_chance = 1.0
	if rod_cast_data == "efficient": bait_use_chance = 0.8
	
	if OptionsMenu.catch_bell: GlobalAudio._play_sound("shop_enter")
	
	if randf() < bait_use_chance: PlayerData._use_bait(casted_bait)
	else: PlayerData._send_notification("The Efficient Lure saved your bait!")
	var max_tier = BAIT_DATA[casted_bait]["max_tier"]
	
	var double_bait = 0.0
	if ["large", "sparkling", "double"].has(rod_cast_data): double_bait = 0.25
	if randf() < double_bait:
		PlayerData._use_bait(casted_bait)
		PlayerData._send_notification("Your lure used extra bait...", 1)
	
	if rod_cast_data == "gold":
		for i in 2: PlayerData._use_bait(casted_bait)
		PlayerData._send_notification("Your golden lure used extra bait...", 1)
	
	var treasure_mult = 1.0
	if rod_cast_data == "magnet":
		junk_mult = 3.0
		treasure_mult = 2.0
	if rod_cast_data == "salty" and not type_lock: fish_type = "ocean"
	if rod_cast_data == "fresh" and not type_lock: fish_type = "lake"
	
	var force_av_size = false
	
	if randf() < 0.05 * junk_mult and not type_lock:
		fish_type = "water_trash"
		max_tier = 0
		force_av_size = true
	
	if in_rain and randf() < 0.08 and not type_lock:
		fish_type = "rain"
	
	
	var rolls = []
	for i in 3:
		var roll = Globals._roll_loot_table(fish_type, max_tier)
		var s = Globals._roll_item_size(roll)
		rolls.append([roll, s])
	
	
	var reroll_type = "none"
	if rod_cast_data == "small": reroll_type = "small"
	if rod_cast_data == "sparkling": reroll_type = "tier"
	if rod_cast_data == "large": reroll_type = "large"
	if rod_cast_data == "gold": reroll_type = "rare"
	
	var chosen = rolls[0]
	for roll in rolls:
		match reroll_type:
			"none":
				chosen = roll
			
			"small":
				if roll[1] < chosen[1]:
					chosen = roll
			
			"large":
				if roll[1] > chosen[1]:
					chosen = roll
			
			"tier":
				var old_tier = Globals.item_data[chosen[0]]["file"].tier
				var new_tier = Globals.item_data[roll[0]]["file"].tier
				if new_tier > old_tier:
					chosen = roll
			
			"rare":
				var new_rare = Globals.item_data[roll[0]]["file"].rare
				if new_rare:
					chosen = roll
	
	var fish_roll = chosen[0]
	var size = chosen[1]
	
	
	var quality = PlayerData.ITEM_QUALITIES.NORMAL
	
	var r = randf()
	for q in PlayerData.ITEM_QUALITIES.size():
		if BAIT_DATA[casted_bait]["quality"].size() - 1 < q:
			print("bait does not support rarity ", q)
			break
		if randf() < (BAIT_DATA[casted_bait]["quality"][q] * fish_zone_data.quality_boost):
			quality = q
	print("-------------------------Rolled Quality: ", quality)
	
	if randf() < 0.02 * treasure_mult and not type_lock:
		fish_roll = "treasure_chest"
		size = 60.0
		quality = 0
	
	var data = Globals.item_data[fish_roll]["file"]
	var quality_data = PlayerData.QUALITY_DATA[quality]
	
	if force_av_size: size = data.average_size
	
	var diff_mult = clamp(size / data.average_size, 0.7, 1.8)
	var difficulty = clamp((data.catch_difficulty * diff_mult * quality_data.diff) + quality_data.bdiff, 1.0, 250.0)
	
	var xp_mult = size / data.average_size
	if xp_mult < 0.15: xp_mult = 1.25 + xp_mult
	xp_mult = max(0.5, xp_mult)
	var xp_add = ceil(data.obtain_xp * xp_mult * catch_drink_xp * quality_data.worth)
	
	print("Total Rolls: ", rolls)
	print("Roll fish ", fish_roll, " with size ", size, " and diff Mult: ", diff_mult)
	
	if fish_zone_data["id"] != - 1:
		_wipe_actor(fish_zone_data["id"])
		Network._send_actor_action(actor_id, "_wipe_actor", [fish_zone_data["id"]])
	
	_enter_state(STATES.FISHING_STRUGGLE)
	animation_data["alert"] = true
	yield(get_tree().create_timer(1.0), "timeout")
	
	animation_data["alert"] = false
	
	var delay_time = 0
	while hud.using_chat:
		yield(get_tree().create_timer(0.15), "timeout")
		delay_time += 1
		
		if delay_time > 200:
			_enter_state(STATES.FISHING_CANCEL)
			return
	
	hud._open_minigame("fishing3", {"fish": fish_roll, "rod_type": rod_cast_data, "reel_mult": catch_drink_reel, "quality": quality, "damage": rod_damage, "speed": rod_spd}, difficulty)
	var success = yield(hud, "_minigame_finished")
	print("SUCCESS: ", success)
	if success:
		animation_data["caught_item"] = {"id": fish_roll, "size": size}
		_enter_state(STATES.FISHING_CANCEL)
		yield(self, "_state_change")
		
		var ref
		var catches = 1
		var bonus_text = []
		
		if rod_cast_data == "double" and randf() < 0.15:
			catches = 2
			bonus_text.append("Your Double Hook doubled the fish!")
		
		if PlayerData.rod_luck_level > 0 and randf() < 0.15:
			bonus_text.append("How lucky! You found a bonus [color=#d57900]Coin Bag[/color] aswell!")
			PlayerData._add_item("luck_moneybag", - 1, randi() % 15 + 15, PlayerData.rod_luck_level)
		
		var tags = []
		
		for i in catches:
			ref = PlayerData._add_item(fish_roll, - 1, size, quality, tags)
			PlayerData._log_item(fish_roll, size, quality)
			PlayerData._quest_progress("catch", fish_roll)
			PlayerData._quest_progress("catch_type", data.loot_table)
			PlayerData._quest_progress("catch_small", PlayerData._get_size_type(fish_roll, size))
			PlayerData._quest_progress("catch_big", PlayerData._get_size_type(fish_roll, size))
			if fish_roll == "treasure_chest": PlayerData._quest_progress("catch_treasure")
			if in_rain: PlayerData._quest_progress("catch_rain")
			if data.tier == 2: PlayerData._quest_progress("catch_hightier")
			xp_buildup += xp_add
			
			PlayerData._catch_fish()
		
		_obtain_item(ref, bonus_text)
		
		if rod_cast_data == "lucky":
			var worth = PlayerData._get_item_worth(ref)
			var gold = max(1, ceil(worth * rand_range(0.01, 0.1)))
			PlayerData.money += gold
			PlayerData._send_notification("Your Lucky Lure got you $" + str(gold) + "!")
		
		if rod_cast_data == "rain" and randf() < 0.06:
			var pos = global_transform.origin
			pos.y += 4.5
			
			var valid = true
			for actor in get_tree().get_nodes_in_group("actor"):
				if actor.owner_id == owner_id and actor.actor_type == "raincloud_tiny":
					valid = false
			
			if valid:
				Network._sync_create_actor("raincloud_tiny", pos, current_zone)
				PlayerData._send_notification("You've summoned a raincloud!")
		
		if catch_drink_gold_add != Vector2(0, 0):
			var gold = max(1, ceil(rand_range(catch_drink_gold_add.x, catch_drink_gold_add.y)))
			PlayerData.money += gold
			PlayerData._send_notification("Your Catcher's Luck got you $" + str(gold) + "!")
		
		if catch_drink_gold_percent > 0.0:
			var worth = PlayerData._get_item_worth(ref)
			var gold = max(1, ceil(rand_range(worth * 0.1, worth * catch_drink_gold_percent)))
			PlayerData.money += gold
			PlayerData._send_notification("Your Catcher's Luck Ultra got you $" + str(gold) + "!")
		
	else:
		_enter_state(STATES.FISHING_CANCEL)

func _wipe_actor(id):
	var actor = world._get_actor_by_id(id)
	print("Wiping actor ", id, " : ", actor)
	if is_instance_valid(actor):
		actor._deinstantiate(true)


func _shovel():
	_enter_state(STATES.SHOVEL_CAST)
	_enter_animation("shovel_dig", false, true, STATES.SHOVEL_STRUGGLE)

func _shovel_check():
	var mound = false
	
	var area
	for a in shovel_area.get_overlapping_areas():
		if a.is_in_group("mound"):
			mound = true
			area = a
	
	if is_instance_valid(area):
		var id = area.owner.actor_id
		_wipe_actor(id)
		Network._send_actor_action(actor_id, "_wipe_actor", [id])
	
	if mound:
		_enter_animation("shovel_struggle", true, true)
		hud._open_minigame("shoveling", {"damage": 5.0})
		var success = yield(hud, "_minigame_finished")
		print("SUCCESS: ", success)
		if success:
			_enter_state(STATES.SHOVEL_CANCEL)
			yield(self, "_state_change")
			var ref = PlayerData._add_item("spider")
			
			
			_obtain_item(ref)
		else:
			_enter_state(STATES.SHOVEL_CANCEL)
	else:
		_enter_state(STATES.SHOVEL_CANCEL)


func _cast_net():
	_enter_state(STATES.NET_CAST)
	_enter_animation("net_use", false, true, STATES.NET_STRUGGLE)

func _net_check():
	var bug = false
	
	var area
	for a in net_area.get_overlapping_areas():
		if a.is_in_group("bug"):
			bug = true
			area = a
	
	var bug_id = ""
	if is_instance_valid(area):
		var id = area.owner.actor_id
		bug_id = area.owner.bug_id
		_wipe_actor(id)
		Network._send_actor_action(actor_id, "_wipe_actor", [id])
	
	if bug:
		_enter_animation("net_struggle", true, true)
		hud._open_minigame("shoveling", {"damage": 5.0})
		var success = yield(hud, "_minigame_finished")
		print("SUCCESS: ", success)
		if success:
			_enter_state(STATES.NET_CANCEL)
			yield(self, "_state_change")
			var size = Globals._roll_item_size(bug_id)
			var ref = PlayerData._add_item(bug_id, - 1, size)
			
			
			_obtain_item(ref)
		else:
			_enter_state(STATES.NET_CANCEL)
	else:
		_enter_state(STATES.NET_CANCEL)





func _toggle_freecam():
	if busy: return
	
	if not freecamming:
		PlayerData._send_notification("entering freecam mode")
		freecamming = true
		hud.freecamming = true
		cam_orbit_node = freecam_anchor
		freecam_anchor.global_transform.origin = global_transform.origin
	else:
		PlayerData._send_notification("exiting freecam mode")
		freecamming = false
		hud.freecamming = false
		cam_orbit_node = null

func _freecam_input(delta):
	if not freecamming: return
	
	var speed = 4.0
	if Input.is_action_pressed("move_sprint"):
		speed = 7.0
	if Input.is_action_pressed("move_sneak"):
		speed = 1.0
	var max_dist = 25.0
	var build_dir = Vector3.ZERO
	
	if Input.is_action_pressed("move_forward"): build_dir -= cam_base.transform.basis.z
	if Input.is_action_pressed("move_back"): build_dir += cam_base.transform.basis.z
	if Input.is_action_pressed("move_right"): build_dir += cam_base.transform.basis.x
	if Input.is_action_pressed("move_left"): build_dir -= cam_base.transform.basis.x
	if Input.is_action_pressed("move_up"): build_dir += cam_base.transform.basis.y
	if Input.is_action_pressed("move_down"): build_dir -= cam_base.transform.basis.y
	
	freecam_anchor.global_transform.origin += build_dir * speed * delta
	
	freecam_anchor.global_transform.origin.x = clamp(freecam_anchor.global_transform.origin.x, global_transform.origin.x - max_dist, global_transform.origin.x + max_dist)
	freecam_anchor.global_transform.origin.y = clamp(freecam_anchor.global_transform.origin.y, global_transform.origin.y - max_dist, global_transform.origin.y + max_dist)
	freecam_anchor.global_transform.origin.z = clamp(freecam_anchor.global_transform.origin.z, global_transform.origin.z - max_dist, global_transform.origin.z + max_dist)





func _create_prop(ref, offset = Vector3(0, 1, 0), restrict_to_one = false):
	if not controlled: return
	
	_refresh_props()
	
	
	if restrict_to_one:
		for prop in prop_ids:
			if prop.ref == ref:
				PlayerData._send_notification("only one of this prop allowed", 1)
				PlayerData.emit_signal("_prop_update")
				return false
	
	
	for prop in prop_ids:
		if prop.ref == ref:
			_wipe_actor(prop.id)
			prop_ids.erase(prop)
			PlayerData._send_notification("clearing prop", 1)
			PlayerData.props_placed = prop_ids
			PlayerData.emit_signal("_prop_update")
			return false
	
	
	if $detection_zones / prop_detect.get_overlapping_bodies().size() > 0 or not is_on_floor() or not $detection_zones / prop_ray.is_colliding():
		PlayerData._send_notification("invalid prop placement", 1)
		return false
	
	
	if prop_ids.size() > 4:
		PlayerData._send_notification("prop limit reached", 1)
		return false
	
	
	var item = PlayerData._find_item_code(ref)
	var data = Globals.item_data[item["id"]]["file"]
	var ver_offset = Vector3(0, 1.0, 0) * (1.0 - player_scale)
	print(ver_offset)
	var pos = global_transform.origin + (global_transform.basis.z * - 2.0) - offset + ver_offset
	var rot = rotation + Vector3(0, deg2rad(180), 0)
	var prop_code = data.prop_code
	
	
	var blacklist = ["island_tiny", "island_med", "island_big"]
	if current_zone_owner != - 1:
		if blacklist.has(prop_code):
			PlayerData._send_notification("this prop cannot be spawned here...", 1)
			return false
	
	
	var new_id = Network._sync_create_actor(prop_code, pos, current_zone, - 1, Network.STEAM_ID, rot, current_zone_owner)
	prop_ids.append({"id": new_id, "ref": ref, "prop_id": data.action})
	PlayerData.props_placed = prop_ids
	PlayerData.emit_signal("_prop_update")
	PlayerData._send_notification("prop placed", 0)
	
	_sync_particle("dust_land", pos, true)
	_sync_sfx("poof", pos)
	
	return true

func _clear_props():
	if prop_ids.size() <= 0:
		PlayerData._send_notification("no props to undo", 1)
		return
	PlayerData._send_notification("undo prop", 0)
	_wipe_actor(prop_ids[prop_ids.size() - 1][0])
	prop_ids.remove(prop_ids.size() - 1)

func _clear_all_props():
	if prop_ids.size() <= 0:
		PlayerData._send_notification("no props to clear", 1)
		return
	
	PlayerData._send_notification("clearing all props", 0)
	for prop in prop_ids:
		_wipe_actor(prop.id)
	prop_ids.clear()
	PlayerData.props_placed = prop_ids
	PlayerData.emit_signal("_prop_update")

func _refresh_props():
	var valid_props = []
	for actor in get_tree().get_nodes_in_group("actor"):
		valid_props.append(actor.actor_id)
	
	print(valid_props)
	
	var kill_props = []
	for prop in prop_ids:
		if not valid_props.has(prop.id): kill_props.append(prop)
	
	for kill in kill_props:
		prop_ids.erase(kill)
	
	PlayerData.props_placed = prop_ids
	PlayerData.emit_signal("_prop_update")

func _item_place_prop(consume = false, restrict_to_one = false, sfx = ""):
	if not controlled: return
	var created = _create_prop(held_item.ref, Vector3(0, 1, 0), restrict_to_one)
	
	if created and consume:
		_enter_state(STATES.DEFAULT)
		consume_on_state_change = held_item["ref"]
		_enter_state(STATES.CONSUME_ITEM)
	
	if created and sfx != "": _sync_sfx(sfx)





func _update_animation_data():
	if animation_data["emote"] != "":
		var anim = $body / player_body / AnimationPlayer.get_animation(animation_data["emote"])
		if anim != null:
			animation_timer += 1
			animation_goal = floor((anim.length * 60) / emote_timescale)
			if animation_timer >= animation_goal and emoting and animation_goal > 0 and not emote_looping:
				print("Finished Emoting ", animation_data["emote"], " bufferstate: ", buffer_state)
				emit_signal("_animation_finished")
				emoting = false
				emote_full = false
				emote_locked = false
				animation_data["emote"] = ""
				if buffer_state != - 1: _enter_state(buffer_state)
	
	var moving = 0
	if direction != Vector3.ZERO or rot_diff > 0.05:
		moving = 1
		if sprinting: moving = 2
		elif sneaking: moving = 3
	
	var emote_state = 0
	if emoting: emote_state = 2 if emote_full else 1
	
	var move_timescale = 1.25
	if slow_walking: move_timescale = 0.7
	elif sprinting: move_timescale = 1.15 * boost_mult
	
	animation_data["emote_state"] = emote_state
	animation_data["moving"] = moving
	animation_data["diving"] = diving
	animation_data["sitting"] = sitting
	animation_data["busy"] = busy and state == STATES.DEFAULT and not emoting
	animation_data["land"] = lerp(animation_data["land"], 0.0, 0.04)
	animation_data["talking"] = lerp(animation_data["talking"], 0.0, 0.1)
	animation_data["recent_reel"] = lerp(animation_data["recent_reel"], recent_reel, 0.2)
	animation_data["player_scale"] = lerp(animation_data["player_scale"], player_scale, 0.06)
	animation_data["move_timescale"] = move_timescale
	animation_data["drunk_tier"] = drunk_tier
	animation_data["state"] = state
	
	$emotion_particles / mushroom_trail.emitting = animation_data["mushroom"]
	$emotion_particles / drunk_particles.emitting = animation_data["drunk_tier"] > 1
	if is_on_floor(): animation_data["mushroom"] = false
	
	if not bobber_control:
		animation_data["bobber_position"] = Vector3(bobber_hpos.x, bobber_vpos, bobber_hpos.z)
	else:
		var pos = global_transform.origin + ( - rod_cast_dist * global_transform.basis.z)
		pos.y = bobber_vpos + sin(OS.get_ticks_msec() * 0.002) * 0.05
		animation_data["bobber_position"] = lerp(animation_data["bobber_position"], pos, 0.2)

func _process_animation():
	if not controlled:
		var keys = animation_data.keys()
		var index = 0
		for i in shared_animation_data:
			animation_data[keys[index]] = i
			index += 1
			if index >= keys.size(): break
	
	var anim_lerp = 0.4
	
	var emote_type = animation_data["emote_state"]
	
	
	
	var anim_moving = animation_data["moving"] != 0
	var anim_sprinting = animation_data["moving"] == 2
	var anim_sneaking = animation_data["moving"] == 3
	
	anim_tree.set("parameters/emote_full/blend_amount", lerp(anim_tree.get("parameters/emote_full/blend_amount"), float(emote_type == 2), anim_lerp))
	if anim_tree.get("parameters/emote_full/blend_amount") < 0.1 and emote_type != 2: anim_tree.set("parameters/emote_full/blend_amount", 0.0)
	anim_tree.set("parameters/emote_half/blend_amount", lerp(anim_tree.get("parameters/emote_half/blend_amount"), float(emote_type == 1), anim_lerp))
	if anim_tree.get("parameters/emote_half/blend_amount") < 0.1 and emote_type != 1: anim_tree.set("parameters/emote_half/blend_amount", 0.0)
	
	anim_tree.set("parameters/arms/blend_amount", lerp(anim_tree.get("parameters/arms/blend_amount"), float(animation_data["emote_state"] == 0), anim_lerp))
	anim_tree.set("parameters/movement/blend_amount", lerp(anim_tree.get("parameters/movement/blend_amount"), float(anim_moving), anim_lerp))
	anim_tree.set("parameters/run_blend/blend_amount", lerp(anim_tree.get("parameters/run_blend/blend_amount"), float(anim_sprinting) - float(anim_sneaking), anim_lerp))
	anim_tree.set("parameters/dive/blend_amount", lerp(anim_tree.get("parameters/dive/blend_amount"), float(animation_data["diving"]), anim_lerp))
	anim_tree.set("parameters/arm_blend/blend_position", float(animation_data["arm_value"]))
	anim_tree.set("parameters/sitting/blend_amount", lerp(anim_tree.get("parameters/sitting/blend_amount"), float(animation_data["sitting"]), anim_lerp))
	anim_tree.set("parameters/thinking/blend_amount", lerp(anim_tree.get("parameters/thinking/blend_amount"), float(animation_data["busy"]), anim_lerp))
	anim_tree.set("parameters/land/blend_amount", lerp(anim_tree.get("parameters/land/blend_amount"), float(animation_data["land"]), anim_lerp))
	anim_tree.set("parameters/talking/blend_amount", lerp(anim_tree.get("parameters/talking/blend_amount"), float(animation_data["talking"]), anim_lerp))
	anim_tree.set("parameters/runmodif/scale", animation_data["move_timescale"])
	anim_tree.set("parameters/walkmodif/scale", animation_data["move_timescale"])
	anim_tree.set("parameters/emote_time/scale", emote_timescale)
	anim_tree.set("parameters/emote_timeb/scale", emote_timescale)
	
	face._show_blush(animation_data["drunk_tier"] > 1)
	if animation_data["caught_item"] != caught_item:
		caught_item = animation_data["caught_item"]
		_update_caught_item(animation_data["caught_item"])
	
	var show_bobber = [STATES.FISHING, STATES.FISHING_CANCEL, STATES.FISHING_CAST, STATES.FISHING_STRUGGLE].has(animation_data["state"])
	var bobber_drop = animation_data["state"] == STATES.FISHING_STRUGGLE
	
	if item_scene:
		item_scene.item_bend = lerp(item_scene.item_bend, animation_data["item_bend"], 0.4)
		bobber_line.end_anchor = item_scene.get_node(item_scene.hotspot_node).global_transform.origin
	bobber_line.y_drop = - 1.5 + ((animation_data["recent_reel"] / 15.0) * 0.5)
	if bobber_drop: bobber_line.y_drop = 0
	if bobber.visible: bobber.global_transform.origin = lerp(bobber.global_transform.origin, animation_data["bobber_position"] + Vector3(0, (0.0 if not bobber_drop else - 0.3), 0), 0.4)
	if bobber.visible != show_bobber:
		bobber.global_transform.origin = animation_data["bobber_position"]
		bobber.visible = show_bobber
	bobber_line.active = bobber.visible
	
	if animation_data["player_scale"] != scale.y:
		scale = clamp(animation_data["player_scale"], 0.6, 1.4) * Vector3.ONE
	
	bobber_line.line_scale = animation_data["player_scale"]
	
	ripples.visible = animation_data["state"] == STATES.FISHING
	var rip_anim = "default" if animation_data["recent_reel"] <= 1.0 else "wake"
	if ripples.animation != rip_anim: ripples.animation = rip_anim
	
	var root = anim_tree.tree_root
	var node = root.get_node("emote_anim")
	var node_b = root.get_node("emote_anim_b")
	if node.animation != animation_data["emote"]:
		var new_anim = animation_data["emote"]
		anim_tree.set("parameters/emote_sync/seek_position", 0.0)
		anim_tree.set("parameters/emote_half_sync/seek_position", 0.0)
		node.set_animation(new_anim)
		node_b.set_animation(new_anim)
		
		emote_timescale = 1.0
		if new_anim == "equip": emote_timescale = 1.5
	
	$"%head_alert".visible = animation_data["alert"]
	
	tail.sitting = animation_data["sitting"]
	tail.diving = animation_data["diving"]
	tail.motion = float(animation_data["moving"])
	tail.wagging = animation_data["wagging"]
	
	
	if animation_data["back_bend"] != 0.0:
		var pose = skeleton.get_bone_pose(1)
		pose = pose.rotated(Vector3(1, 0, 0), animation_data["back_bend"])
		skeleton.set_bone_custom_pose(1, pose)
	else:
		skeleton.set_bone_custom_pose(1, Transform())

func _share_animation_data():
	if not controlled: return
	
	
	shared_animation_data = animation_data.values()
	
	var vec = shared_animation_data[0]
	shared_animation_data[0] = Vector3(stepify(vec.x, 0.01), stepify(vec.y, 0.01), stepify(vec.z, 0.01))
	
	
	Network._send_actor_animation_update(actor_id, shared_animation_data)

func _enter_animation(anim_name, loop = false, _locked = true, state_enter = - 1, full_anim = true):
	if anim_name == animation_data["emote"]: return
	diving = false
	
	
	emote_full = full_anim
	emote_locked = _locked
	emote_looping = loop
	buffer_state = state_enter if not emote_looping else - 1
	if emote_looping: _enter_state(state_enter)
	animation_data["emote"] = anim_name
	animation_timer = 0
	emoting = true

func _exit_animation():
	emit_signal("_animation_finished")
	emoting = false
	emote_full = false
	emote_locked = false
	emote_looping = false
	animation_data["emote"] = ""

func _update_held_item(new):
	if new.empty() or held_item == new: return
	
	held_item = new
	var item_data = Globals.item_data[new["id"]]["file"]
	var alt_scale_mult = 1.0
	
	
	item_sprite.texture = item_data.icon.duplicate() if (item_data.show_item and not item_data.show_scene) else null
	
	
	
	if is_instance_valid(item_scene): item_scene.queue_free()
	item_scene = null
	if item_data.show_scene and item_data.item_scene:
		item_scene = item_data.item_scene.instance()
		hand_bone.add_child(item_scene)
	
	var final_size = clamp(new["size"], 0.01, 12000.0)
	var scale_mult = 0.07 - clamp(final_size * 0.01, 0.01, 0.061)
	var item_scale = 1.0 if not item_data.uses_size else final_size * scale_mult
	item_scale *= alt_scale_mult
	item_sprite.scale = Vector3(item_scale, item_scale, item_scale)
	
	
	var y = 0.0
	var offs = 0.0
	var back_bend = 0.0
	if item_data.uses_size:
		y = clamp(item_scale * item_scale * 0.08, 0.0, 0.36)
		offs = clamp(item_scale * item_scale, 0.0, 16.0)
		back_bend = clamp(item_scale * item_scale, 0.0, 55.0)
	
	item_sprite.translation.y = y
	item_sprite.offset.y = item_data.hold_offset + offs
	
	
	$body / player_body / Armature / Skeleton / BoneAttachment / Spatial.rotation_degrees = Vector3(0.0, 0.0, back_bend * 0.7)
	
	item_sprite.translation.z = 0.0
	item_sprite.vel = 0.0
	item_sprite.mult = clamp(item_scale * 3.5, 0.0, 1.2) if item_data.category == "fish" and item_data.alive else 0.0
	
	item_sprite.modulate = Color("#ffffff")
	item_sprite.opacity = 1.0
	for child in item_sprite.get_children(): child.emitting = false
	
	if PlayerData.QUALITY_DATA.has(new["quality"]):
		item_sprite.modulate = Color(PlayerData.QUALITY_DATA[new["quality"]]["mod"])
		item_sprite.opacity = PlayerData.QUALITY_DATA[new["quality"]]["op"]
		if PlayerData.QUALITY_DATA[new["quality"]]["particle"] > - 1: item_sprite.get_child(PlayerData.QUALITY_DATA[new["quality"]]["particle"]).emitting = true
	
	animation_data["arm_value"] = item_data.arm_value
	animation_data["back_bend"] = deg2rad( - back_bend)

func _update_caught_item(new):
	if typeof(new) != TYPE_DICTIONARY:
		new = PlayerData.FALLBACK_ITEM
	
	if new.empty():
		caught_fish.texture = null
		return
	caught_item = new
	
	var item_data = Globals.item_data[new["id"]]["file"]
	caught_fish.texture = item_data.icon.duplicate() if item_data.show_item else null
	
	var item_scale = 1.0 if not item_data.uses_size else new["size"] * 0.01
	caught_fish.scale = Vector3(item_scale, item_scale, item_scale)

func _bobber_cast(dist, end, splash):
	bobber_control = false
	var height = dist * 0.4
	height += max(0, global_transform.origin.y - end.y)
	
	end.y -= 1
	
	bobber_hpos = global_transform.origin
	bobber_vpos = global_transform.origin.y
	yield(get_tree().create_timer(0.4), "timeout")
	
	var tween = get_tree().create_tween()
	
	tween.set_trans(1)
	tween.set_ease(1)
	tween.tween_property(self, "bobber_vpos", end.y + height, dist * 0.05)
	tween.set_ease(0)
	tween.tween_property(self, "bobber_vpos", end.y - (height * 0.2), dist * 0.05)
	if splash:
		tween.tween_callback(self, "_bobber_splash")
	
	
	tween.set_trans(1)
	tween.set_ease(1)
	tween.tween_property(self, "bobber_vpos", end.y + (height * 0.1), (dist * 0.05))
	tween.set_ease(0)
	tween.tween_property(self, "bobber_vpos", end.y - (height * 0.05), (dist * 0.1))
	

	tween.set_trans(1)
	tween.set_ease(1)
	tween.tween_property(self, "bobber_vpos", end.y, (dist * 0.1))
	
	var htween = get_tree().create_tween()
	htween.set_trans(4)
	htween.set_ease(1)
	htween.tween_property(self, "bobber_hpos", end + (global_transform.basis.z * 0.5), dist * 0.1)
	htween.tween_property(self, "bobber_hpos", end + (global_transform.basis.z * 0.2), dist * 0.15)
	htween.tween_property(self, "bobber_hpos", end, dist * 0.1)
	
	yield(htween, "finished")
	bobber_control = true

func _bobber_retract():
	bobber_control = false
	bobber_hpos = bobber.global_transform.origin
	bobber_vpos = bobber.global_transform.origin.y
	
	yield(get_tree().create_timer(0.4), "timeout")
	
	if retract_splash: _bobber_splash("splashb")
	var tween = get_tree().create_tween()
	tween.set_trans(1)
	tween.set_ease(1)
	tween.tween_property(self, "bobber_vpos", global_transform.origin.y + 2.0, 0.3)
	tween.set_ease(0)
	tween.tween_property(self, "bobber_vpos", global_transform.origin.y, 0.3)
	
	var htween = get_tree().create_tween()
	htween.tween_property(self, "bobber_hpos", global_transform.origin, 0.6)

func _bobber_splash(sfx = "splash"):
	_sync_particle("splash", bobber.global_transform.origin, true)
	_sync_sfx(sfx, Vector3(bobber_hpos.x, bobber_vpos, bobber_hpos.z))





func _toggle_sit(exit = false):
	if not exit: sitting = not sitting
	else: sitting = false

func _play_emote(emote_id, emotion = ""):
	if emote_id == "": return
	
	if emote_id == "sit":
		_toggle_sit()
	elif not emote_locked:
		_enter_animation(emote_id, false, true)
		if emotion != "":
			_sync_face_emote(emotion)





func _change_cosmetics():
	if cosmetic_data == PlayerData.cosmetics_equipped: return
	var new = PlayerData.cosmetics_equipped.duplicate()
	if not dead_actor: Network._send_actor_action(actor_id, "_update_cosmetics", [new])
	_update_cosmetics(new)

func _update_cosmetics(data):
	var valid = true
	for key in PlayerData.FALLBACK_COSM.keys():
		if not data.keys().has(key):
			print("missing key ", key)
			valid = false
	for key in data.keys():
		if not (data[key] is Array):
			if not Globals._cosmetic_exists(data[key]):
				print("cosm ", data[key], " does not exist")
				valid = false
		else:
			for c in data[key]:
				if not Globals._cosmetic_exists(c):
					print("cosm ", data[key], " does not exist")
					valid = false
	
	if not valid: data = PlayerData.FALLBACK_COSM.duplicate()
	if data.empty(): return
	
	var username = str(Network._get_username_from_id(owner_id))
	if username == "null": username = "Player"
	
	var new_title = Globals.cosmetic_data[data["title"]]["file"].title
	var contrib_titles = [
		"title_stupididiotbaby", 
		"title_imnormal", 
		"title_bipedalanimaldrawer", 
		"title_hazard", 
		"title_cadaverdog", 
		"title_nitrousoxide", 
		"title_admiral", 
		"title_nitrousoxide", 
		"title_igloo", 
		"title_zed", 
		"title_specialforces", 
		"title_candy", 
		"title_lamedev_real"]
	if contrib_titles.has(data["title"]) and not Network.KNOWN_CONTRIBUTORS.has(owner_id):
		new_title = "Scout"
	
	title.label = username
	title.title = new_title
	title.player_id = owner_id
	title._update_title()
	
	if known_cosmetic_data == data: return
	
	cosmetic_data = data
	known_cosmetic_data = data
	
	for child in skeleton.get_children():
		if child.is_in_group("cosmetic"): child.queue_free()
	
	face._setup_face(data)
	var species_id = Globals.cosmetic_data[data.species]["file"].cos_internal_id
	var species = _create_cosmetic(data["species"], species_id)
	_create_cosmetic(data["undershirt"], species_id)
	_create_cosmetic(data["overshirt"], species_id)
	_create_cosmetic(data["legs"], species_id)
	_create_cosmetic(data["hat"], species_id)
	for misc in data["accessory"]: _create_cosmetic(misc, species_id)
	
	
	var pattern = Globals.cosmetic_data[data["pattern"]]["file"]
	body_mesh.material_override.set_shader_param("texture_albedo", pattern.body_pattern[0])
	
	var primary_color = Globals.cosmetic_data[data["primary_color"]]["file"]
	var secondary_color = Globals.cosmetic_data[data["secondary_color"]]["file"] if pattern.body_pattern[0] else Globals.cosmetic_data[data["primary_color"]]["file"]
	body_mesh.material_override.set_shader_param("albedo", primary_color.main_color)
	body_mesh.material_override.set_shader_param("albedo_secondary", secondary_color.main_color)
	
	
	var tail_data = Globals.cosmetic_data[data["tail"]]["file"]
	tail._load_tail(tail_data.mesh, primary_color.main_color)
	
	if species:
		
		
		species.material_override = null
		
		match data["species"]:
			"species_cat":
				species.set_surface_material(0, preload("res://Assets/Shaders/player_skins.tres").duplicate())
				species.get_surface_material(0).set_shader_param("albedo", primary_color.main_color)
				species.get_surface_material(0).set_shader_param("albedo_secondary", secondary_color.main_color)
				species.get_surface_material(0).set_shader_param("texture_albedo", pattern.body_pattern[1])
			"species_dog":
				species.set_surface_material(0, preload("res://Assets/Shaders/player_skins.tres").duplicate())
				species.get_surface_material(0).set_shader_param("albedo", primary_color.main_color)
				species.get_surface_material(0).set_shader_param("albedo_secondary", secondary_color.main_color)
				species.get_surface_material(0).set_shader_param("texture_albedo", pattern.body_pattern[2])
	
	if not data.keys().has("bobber") or data["bobber"] == "": data["bobber"] = "bobber_default"
	var bobber_file = Globals.cosmetic_data[data["bobber"]]["file"]
	bobber_mesh.mesh = bobber_file.mesh
	bobber_mesh.set_surface_material(0, bobber_file.material)
	if bobber_file.secondary_material: bobber_mesh.set_surface_material(1, bobber_file.secondary_material)
	if bobber_file.third_material: bobber_mesh.set_surface_material(2, bobber_file.third_material)

func _create_cosmetic(id, species_id = 0):
	if id == "": return
	if not Globals.cosmetic_data.keys().has(id):
		print("Failed finding cosmetic: ", id)
		return
	print("Creating Cosmetic: ", id)
	var data = Globals.cosmetic_data[id]["file"]
	
	if data.scene_replace:
		var bone_attach = BoneAttachment.new()
		skeleton.add_child(bone_attach)
		bone_attach.bone_name = "pelvis"
		bone_attach.add_to_group("cosmetic")
		
		var cosm = data.scene_replace.instance()
		bone_attach.add_child(cosm)
		return cosm
	
	var cosm = preload("res://Scenes/Entities/Player/cosmetic_node.tscn").instance()
	cosm.mesh = data.mesh
	if data.species_alt_mesh.size() > 0:
		cosm.mesh = data.species_alt_mesh[species_id]
	
	cosm.skin = data.mesh_skin
	
	if not data.material:
		cosm.material_override = preload("res://Assets/Shaders/player_skins.tres").duplicate()
		cosm.material_override.set_shader_param("albedo", data.main_color)
		cosm.material_override.set_shader_param("albedo_secondary", data.main_color)
		cosm.material_override.set_shader_param("texture_albedo", null)
	else:
		
		cosm.material_override = null
		cosm.set_surface_material(0, data.material)
		if data.secondary_material: cosm.set_surface_material(1, data.secondary_material)
	
	cosm.skeleton = skeleton.get_path()
	skeleton.add_child(cosm)
	return cosm


















func _on_step_timer_timeout():
	if not controlled: return
	
	
	if randf() < 0.03 * drunk_tier and drunk_wander_length <= 0:
		drunk_wander_length = randi() % 25 + 5
		drunk_wander_dir = Vector3(
			rand_range( - 1, 1), 
			0.0, 
			rand_range( - 1, 1))
	
	
	if drunk_tier == 4 and randf() < 0.01:
		if randf() < 0.6:
			snapped = false
			diving = true
			dive_vec = - transform.basis.z.normalized() * dive_distance * dive_bonus * 0.35
			dive_vec.y = 0
			gravity_vec += Vector3(0, jump_height * 0.5 * dive_bonus, 0)
		else:
			var emote = randi() % 6
			match emote:
				0: _play_emote("sit", "")
				1: _play_emote("emote_love", "love")
				2: _play_emote("emote_angry", "angry")
				2: _play_emote("emote_sad", "sad")
				3: _play_emote("emote_surprised", "surprised")
				4: _play_emote("emote_cheer", "happy")
				5: _play_emote("emote_bark", "bark_ready")
	
	if state == STATES.FISHING_STRUGGLE:
		_sync_particle("small_splash", bobber.global_transform.origin, true)
	
	if recent_reel > 0 and state == STATES.FISHING:
		fishing_update.translation.z = - rod_cast_dist
		fishing_update.force_raycast_update()
		if fishing_update.is_colliding() and not fishing_update.get_collider().is_in_group("valid_water"):
				_enter_state(STATES.FISHING_CANCEL)
	
	if velocity != Vector3.ZERO:
		var vol = 1.6
		if sprinting: vol = 2.8
		elif sneaking: vol = 0.3
		
		if is_on_floor() and sprinting: _sync_particle("dust_run", Vector3(0, - 0.95, 0))
	
	if is_on_floor() and safe_check.is_colliding() and safe_check.get_collision_normal() == Vector3(0, 1, 0) and not gravity_disable:
		if death_counter > 0: death_counter -= 1
		last_valid_pos = global_transform.origin
	
	PlayerData.player_saved_position = global_transform.origin





func _message_sent(text):
	
	var split = text.split(" ")
	for s in split:
		match s:
			":(", ":[", "D:", ";_;", ";~;", ":C", ":c": _sync_face_emote("sad")
			":)", ":D", ":]": _sync_face_emote("love")
			"xD", "!!!", "<3", "xd", "LMAO", "LOL": _sync_face_emote("happy")
			">:(", "D:<", ">:[": _sync_face_emote("angry")
			":/", ":|": _sync_face_emote("flat")
			":3", ":3c", ">:3c", ">:3": _sync_face_emote("cat")
			"O.o", "!?!?", "?!?!", ":o", ":O": _sync_face_emote("surprised")
	
	var bubble = title._create_speech_bubble(text, PlayerData.voice_speed)
	bubble.connect("_letter_said", self, "_sync_talk")
	Network._send_actor_action(actor_id, "_sync_create_bubble", [text], false)

func _sync_talk(letter):
	if PlayerData.players_muted.has(owner_id): return
	
	var blacklist = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
	if not blacklist.has(letter.to_lower()): return
	
	animation_data["talking"] = 0.4
	_talk(letter, PlayerData.voice_pitch)
	Network._send_actor_action(actor_id, "_talk", [letter, PlayerData.voice_pitch], false, Network.CHANNELS.SPEECH)

func _talk(letter, pitch = 1.5):
	if not in_zone or not visible: return
	if PlayerData.players_muted.has(owner_id): return
	
	pitch = clamp(pitch, 0.5, 2.0)
	
	face._talk()
	sound_manager._construct_voice(letter, "NewVoice", pitch)

func _sync_face_emote(emotion):
	_face_emote(emotion)
	Network._send_actor_action(actor_id, "_face_emote", [emotion], false)

func _sync_create_bubble(text):
	if PlayerData.players_muted.has(owner_id): return
	
	title._create_speech_bubble(text)

func _sync_level_bubble(text):
	title._create_level_bubble(text)
	$emotion_particles / lvl_particles.restart()
	$emotion_particles / lvl_particles2.restart()

func _face_emote(emotion):
	face._emote(emotion, 2.4)





func _sync_particle(id, offset = Vector3.ZERO, global = false):
	_play_particle(id, offset, global)
	Network._send_actor_action(actor_id, "_play_particle", [id, offset, global], false)

func _play_particle(id, offset, global):
	if not PARTICLE_DATA.keys().has(id): return
	if get_tree().get_nodes_in_group(str(owner_id) + "_particle").size() > 20: return
	
	var p = PARTICLE_DATA[id].instance()
	add_child(p)
	p.add_to_group(str(owner_id) + "_particle")
	
	if not global:
		p.translation = offset
	else:
		p.set_as_toplevel(true)
		p.global_transform.origin = offset
	
	p.emitting = true
	yield(get_tree().create_timer(p.lifetime + 0.1), "timeout")
	p.queue_free()





func _on_water_detect_area_entered(area):
	if gravity_disable: return
	if area.is_in_group("water"):
		_kill()

func _kill(skip_anim = false):
	if not controlled: return
	
	var send_to_zone = ""
	var send_to_zone_spawn_id = ""
	var show_particles = true
	
	death_counter += 1
	if death_counter >= 10:
		if not skip_anim: PlayerData._send_notification("too many deaths in a row! sending to spawn...", 1)
		else: PlayerData._send_notification("returning to spawn", 1)
		
		send_to_zone = "main_zone"
		send_to_zone_spawn_id = "return_spawn"
		last_valid_pos = world.map.spawn_position.global_transform.origin
		death_counter = 0
	
	for area in $raincloud_check.get_overlapping_areas():
		if area.is_in_group("death_transport_zone"):
			send_to_zone = area.zone_travel
			send_to_zone_spawn_id = area.spawn_id
			show_particles = false
			Network._update_chat(area.intro_text)
	
	if state == STATES.FISHING or state == STATES.FISHING_CAST or state == STATES.FISHING_CAST:
		_enter_state(STATES.FISHING_CANCEL)
	
	cam_push = 0.0
	gravity_disable = true
	
	if not skip_anim:
		_enter_animation("drown", true, true)
		
		if show_particles:
			_sync_sfx("drown")
			_sync_particle("splash", global_transform.origin, true)
	
	SceneTransition._fake_scene_change()
	yield(SceneTransition, "_finished")
	
	if send_to_zone == "":
		global_transform.origin = last_valid_pos + Vector3(0, 0.5, 0)
	else:
		_enter_zone(send_to_zone, send_to_zone_spawn_id)
	
	yield(get_tree().create_timer(0.3), "timeout")
	gravity_disable = false
	_enter_state(0)
	_exit_animation()





func _consume_item(id):
	if state != STATES.DEFAULT: return
	_enter_state(STATES.EMOTING)
	
	consume_on_state_change = held_item["ref"]
	_enter_animation("drink", false, true, STATES.CONSUME_ITEM, true)
	
	var sfx = "drink"
	
	match id:
		"growth": player_scale = clamp(player_scale + 0.1, 0.7, 1.3)
		"shrink": player_scale = clamp(player_scale - 0.1, 0.7, 1.3)
		"revert":
			player_scale = 1.0
			drunk_timer = max(drunk_timer - 20000, 0)
			sfx = "drink_nocap"
		"speed":
			boost_timer = 18000
			boost_amt = 1.3
			sfx = "drink_nocap"
		"speed_burst":
			boost_timer = 900
			boost_amt = 4.0
			sfx = "drink_nocap"
		"catch":
			catch_drink_timer = 18000
			catch_drink_boost = 1.15
			catch_drink_reel = 1.25
			catch_drink_xp = 1.0
			catch_drink_tier = 1
			catch_drink_gold_add = Vector2(1, 10)
			catch_drink_gold_percent = 0.0
		"catch_big":
			catch_drink_timer = 18000
			catch_drink_boost = 1.3
			catch_drink_reel = 1.45
			catch_drink_xp = 1.0
			catch_drink_tier = 2
			catch_drink_gold_add = Vector2(0, 0)
			catch_drink_gold_percent = 0.25
		"catch_deluxe":
			catch_drink_timer = 18000
			catch_drink_boost = 1.3
			catch_drink_reel = 1.45
			catch_drink_xp = 1.25
			catch_drink_tier = 3
			catch_drink_gold_add = Vector2(0, 0)
			catch_drink_gold_percent = 0.0
		"beer":
			drunk_timer += 9000
			drunk_timer = clamp(drunk_timer, 0, 100000)
		"beer_big":
			drunk_timer += 42000
			drunk_timer = clamp(drunk_timer, 0, 100000)
			sfx = "drink_nocap"
		"bounce":
			jump_bonus_tier = 1
			jump_bonus_timer = 1200
			jump_bonus = 2.0
			dive_bonus = 2.0
		"bounce_big":
			jump_bonus_tier = 2
			jump_bonus_timer = 600
			jump_bonus = 4.0
			dive_bonus = 3.5
	
	_sync_sfx(sfx)
	


func _open_chest(rare = false):
	if state != STATES.DEFAULT: return
	
	consume_on_state_change = held_item["ref"]
	_enter_state(STATES.CONSUME_ITEM)
	
	var cosm = PlayerData._get_unowned_cosmetic()
	if cosm != null: PlayerData._unlock_cosmetic(cosm)
	else:
		PlayerData._send_notification("You found 100 dollars inside the chest!")
		PlayerData.money += 100

func _open_ringbox():
	if state != STATES.DEFAULT: return
	
	consume_on_state_change = held_item["ref"]
	_enter_state(STATES.CONSUME_ITEM)
	
	if not PlayerData.cosmetics_unlocked.has("accessory_ring"): PlayerData._unlock_cosmetic("accessory_ring")
	else:
		PlayerData._send_notification("You already have a ring unlocked... Obtained $1000 instead.")
		PlayerData.money += 1000



func _scratch_off(type):
	_enter_state(STATES.GUITAR)
	hud._open_minigame("scratch_off", {"type": type})
	var _win = yield(hud, "_minigame_finished")
	yield(get_tree().create_timer(0.15), "timeout")
	_enter_state(STATES.DEFAULT)
	
	consume_on_state_change = held_item["ref"]
	_enter_state(STATES.CONSUME_ITEM)
	
	if not _win:
		_sync_face_emote("angry")
		_sync_sfx("rip")
	else:
		_sync_face_emote("happy")


func _open_labeler():
	_enter_state(STATES.GUITAR)
	hud._open_minigame("hand_labeler")
	var _win = yield(hud, "_minigame_finished")
	yield(get_tree().create_timer(0.15), "timeout")
	_enter_state(STATES.DEFAULT)





func _mushroom_bounce():
	if not controlled: return
	ignore_snap = 10
	var bounce_horz = 16.0 if direction != Vector3.ZERO else 0.0
	var bounce_vert = 32.0
	gravity_vec = Vector3.ZERO
	gravity_vec.x += (direction.normalized() * bounce_horz).x
	gravity_vec.z += (direction.normalized() * bounce_horz).z
	gravity_vec.y += bounce_vert
	animation_data["mushroom"] = true





func _sync_sfx(id, position = null, pitch = 1.0, delay = 0.0):
	if not controlled: return
	
	if delay > 0.0: yield(get_tree().create_timer(delay), "timeout")
	
	_play_sfx(id, position, pitch)
	Network._send_actor_action(actor_id, "_play_sfx", [id, position, pitch], false)

func _play_sfx(id, position = null, pitch = 1.0):
	if not in_zone or not visible: return
	if PlayerData.players_muted.has(owner_id): return
	
	if is_nan(pitch) or pitch <= 0 or pitch >= INF: return
	pitch = clamp(pitch, 0.1, 2.5)
	
	sound_manager._play_sound(id, position, pitch)
	print("playing sfx ", id)

func _process_sounds():
	if $sound_manager / dive_scrape.playing != animation_data["dive_scrape"]: $sound_manager / dive_scrape.playing = animation_data["dive_scrape"] and in_zone
	if $sound_manager / reel_slow.stream_paused == animation_data["reel_slow"]: $sound_manager / reel_slow.stream_paused = not animation_data["reel_slow"] and in_zone
	if $sound_manager / reel_fast.playing != animation_data["reel_fast"]: $sound_manager / reel_fast.playing = animation_data["reel_fast"] and in_zone





func _on_rain_timer_timeout():
	if not controlled: return
	
	var rain = false
	for child in $raincloud_check.get_overlapping_areas():
		if child.is_in_group("rain_cloud"):
			rain = true
	
	if rain != in_rain:
		in_rain = rain
		PlayerData.emit_signal("_rain_toggle", in_rain)
	
	if not in_rain: Network.set_rich_presence("#default")
	else: Network.set_rich_presence("#rain")





func _wag():
	animation_data["wagging"] = not animation_data["wagging"]

func _paint(size, color):
	if not controlled: return
	
	var in_zone = false
	for area in $paint_node / Area.get_overlapping_areas():
		if area.is_in_group("canvas"): in_zone = true
	if not in_zone: PlayerData._send_notification("mouse must be on a drawing zone!", 1)
	
	$paint_node.size = size
	$paint_node.color = color
	$paint_node.drawing = true

func _paint_stop():
	if not controlled: return
	$paint_node.drawing = false
	PlayerData.emit_signal("_chalk_send")

func _metal_detect_begin():
	pass

func _metaldetect_update():
	if not controlled or held_item.id == "":
		return
	
	var idata = Globals.item_data[held_item["id"]]["file"]
	if not idata.detect_item:
		return
	
	var alert_level = 0
	for b in $detection_zones / metal_detect_far.get_overlapping_bodies():
		if b.is_in_group("metal_spawn"):
			if abs(b.global_transform.origin.y - global_transform.origin.y) > 3.5: continue
			alert_level = b.global_transform.origin.distance_to(global_transform.origin)
	
	metal_detect_alert_level = alert_level
	
	if alert_level > 0: _metal_detect_beep()

func _metal_detect_beep():
	var new_cd = ceil(max(metal_detect_alert_level * 0.5, 1))
	
	if abs(new_cd - metal_detect_alert_cd) > 4: metal_detect_alert_cd = 0
	
	metal_detect_alert_cd -= 1
	if metal_detect_alert_cd > 0: return
	
	metal_detect_alert_cd = new_cd
	
	var pitch = max(6.0 - metal_detect_alert_level * 0.3, 0.5)
	
	$metaldetect_dot.modulate.a = 1.0
	if metal_detect_flop: _sync_sfx("md_beep_slowb", null, pitch)
	else: _sync_sfx("md_beep_slow", null, pitch)
	metal_detect_flop = not metal_detect_flop

func _on_metal_detect_consume_body_entered(b):
	if not controlled or held_item.id == "": return
	
	var idata = Globals.item_data[held_item["id"]]["file"]
	if not idata.detect_item: return
	
	if b.is_in_group("metal_spawn"):
		b._reveal()

func _on_image_update_timeout():
	if not controlled or dead_actor: return
	_update_held_item(held_item)
	Network._send_actor_action(actor_id, "_update_held_item", [held_item], false)

func _real_step(run = false):
	if anim_tree.get("parameters/dive/blend_amount") > 0.2 or anim_tree.get("parameters/movement/blend_amount") < 0.8: return
	if not is_on_floor(): return
	var sfx = "step" if not run else "step_run"
	if boost_amt > 1.0 and boost_timer > 1: sfx = "step_fastrun"
	_sync_sfx(sfx)



func _play_guitar():
	_enter_state(STATES.GUITAR)
	hud._open_minigame("guitar")
	var _win = yield(hud, "_minigame_finished")
	yield(get_tree().create_timer(0.15), "timeout")
	_enter_state(STATES.DEFAULT)

func _strum_guitar(string, fret, volume):
	_sync_strum(string, fret, volume)
	Network._send_actor_action(actor_id, "_sync_strum", [string, fret, volume], true, Network.CHANNELS.GUITAR)
	
	animation_data["land"] = clamp(animation_data["land"] + 0.06, 0.0, 0.3)
	_sync_face_emote("strum")
	if randf() < 0.05:
		_sync_particle("music")

func _sync_strum(string, fret, volume):
	if not in_zone or not visible: return
	$guitar_sounds.get_child(string)._play_fret(fret, false, volume)

func _hammer_string(string, fret):
	_sync_hammer(string, fret)
	Network._send_actor_action(actor_id, "_sync_hammer", [string, fret])

func _sync_hammer(string, fret):
	if not in_zone or not visible: return
	$guitar_sounds.get_child(string)._hammer_fret(fret)

func _bark():
	if not controlled: return
	var bark_id = ["bark_cat", "growl_cat", "whine_cat"]
	bark_id = {
		"species_cat": ["bark_cat", "growl_cat", "whine_cat"], 
		"species_dog": ["bark_dog", "growl_dog", "whine_dog"], 
	}[PlayerData.cosmetics_equipped.species]
	
	var type = 0
	if Input.is_action_pressed("move_sneak"):
		_sync_face_emote("growl")
		type = 1
	elif Input.is_action_pressed("move_walk"):
		_sync_face_emote("whine")
		type = 2
	else:
		_sync_face_emote("bark")
	
	bark_id = bark_id[type]
	_sync_sfx(bark_id)

func _kiss():
	if not controlled: return
	
	animation_data["land"] = animation_data["land"] + 0.2
	_sync_face_emote("kiss")
	_sync_sfx("kiss")
	_sync_particle("kiss")

func _punch(type = 0):
	if not controlled or item_cooldown > 0: return
	item_cooldown = 30
	
	animation_data["land"] = animation_data["land"] + 1.0
	for b in $detection_zones / punch.get_overlapping_bodies():
		if b.is_in_group("player") and b != self and not b.controlled:
			Network._send_P2P_Packet({"type": "player_punch", "from_pos": global_transform.origin, "punch_type": type}, str(b.owner_id), 2, Network.CHANNELS.ACTOR_ACTION)
	
	punch_count += 1
	PlayerData.punching_alot = punch_count > 10
	
	_sync_face_emote("punch")
	_sync_sfx("punch")
	_sync_punch()
	Network._send_actor_action(actor_id, "_sync_punch")

func _sync_punch():
	$emotion_particles / punch_particles.restart()
	$emotion_particles / punchb_particles.restart()

func _punched(from, type):
	if not controlled: return
	
	if OptionsMenu.punchable: return
	
	var dist = from.distance_to(global_transform.origin)
	if dist > 2.5: return
	
	var dir = (global_transform.origin - from).normalized()
	
	punch_count += 1
	PlayerData.punching_alot = punch_count > 10
	
	ignore_snap = 10
	var bounce_horz = 4.0
	var bounce_vert = 8.0
	
	match type:
		0:
			bounce_horz = 4.0
			bounce_vert = 8.0
		1:
			bounce_horz = 12.0
			bounce_vert = 24.0
	
	gravity_vec = Vector3.ZERO
	gravity_vec.x += (dir.normalized() * bounce_horz).x
	gravity_vec.z += (dir.normalized() * bounce_horz).z
	gravity_vec.y += bounce_vert
	
	_sync_face_emote("angry")

func _tambourine():
	_sync_sfx("tambourine")
	
	animation_data["land"] = clamp(animation_data["land"] + 0.14, 0.0, 0.3)
	_sync_face_emote("strum")
	if randf() < 0.25:
		_sync_particle("music")

func _on_cosmetic_refresh_timeout():
	if not controlled: return
	_refresh_cosmetics()
	punch_count -= 10
	PlayerData.punching_alot = punch_count > 10

func _refresh_cosmetics():
	if not controlled: return
	yield(get_tree().create_timer(1.0), "timeout")
	var new = PlayerData.cosmetics_equipped.duplicate()
	if not dead_actor: Network._send_actor_action(actor_id, "_update_cosmetics", [new])

func _return_to_spawn():
	if not controlled: return
	death_counter = 11
	_kill(true)

func _item_removal(ref):
	print("Sold Item")
	if held_item.keys().has("ref") and held_item["ref"] == ref: _equip_item(PlayerData.FALLBACK_ITEM.duplicate())
