extends Actor

const GRAVITY = 32.0

var bug_id = ""
var immobile = false

var speed = 1.2
var run_speed = 5.5
var accel = 64.0
var velocity = Vector3()
var direction = Vector3()
var gravity_vec = Vector3()
var snapped = false
var scared = false
var state_timer = 30
var bump_cd = 0

onready var ray = $RayCast

func _ready():
	custom_saved_data["bug_id"] = bug_id
	var data = Globals.item_data[bug_id]["file"]
	$Sprite3D.texture = data.icon.duplicate()

func _controlled_process(delta):
	_process_movement(delta)
	_update_state()

func _process_movement(delta):
	if is_on_floor():
		gravity_vec = get_floor_normal() * - 1.0
		snapped = true
	elif snapped:
		gravity_vec = Vector3.ZERO
		snapped = false
	else:
		var grav = GRAVITY * Vector3.DOWN * delta
		gravity_vec += grav
	
	if immobile:
		gravity_vec = Vector3.ZERO
		direction = Vector3(0, 1, 0)
		speed = 0
	
	var _speed = speed if not scared else run_speed
	var _accel = accel if is_on_floor() else accel * 0.35
	
	if scared:
		scale = scale.move_toward(Vector3.ZERO, delta)
	
	velocity = velocity.move_toward(direction.normalized() * _speed, delta * _accel)
	move_and_slide(velocity + gravity_vec, Vector3.UP)
	
	bump_cd -= 1
	ray.cast_to = direction * 1.5
	ray.cast_to.y = 0
	if ray.is_colliding() and bump_cd <= 0:
		direction = - direction.normalized()
		bump_cd = 5

func _update_state():
	state_timer -= 1
	if state_timer <= 0 and not scared:
		if randf() < 0.4:
			direction.x = rand_range( - 1.0, 1.0)
			direction.z = rand_range( - 1.0, 1.0)
			direction = direction.normalized()
		else:
			direction = Vector3.ZERO
		state_timer = randi() % 120 + 30

func _scare(from, force = false):
	if not controlled and not force: return
	direction = (global_transform.origin - from).normalized()
	direction.y = 0
	if not scared: decay_timer = 180
	scared = true

func _owner_dc():
	_scare(global_transform.origin, true)
