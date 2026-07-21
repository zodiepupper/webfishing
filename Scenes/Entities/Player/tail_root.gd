extends Spatial

var default_rot = Vector3(140, 0, - 6)
var sitting = false
var diving = false
var motion = 0.0
var wagging = false
var wag = 0.0

onready var rot = $rot_point
onready var swish = $rot_point / swish_point
onready var tail = $rot_point / swish_point / tail

func _ready():
	swish.set_as_toplevel(true)

func _physics_process(delta):
	var des_rot = default_rot
	des_rot.x += sin(OS.get_ticks_msec() * 0.0005) * 8
	des_rot.x += sin(OS.get_ticks_msec() * 0.01) * 3 * motion
	
	
	
	
	if not wagging: wag = sin(OS.get_ticks_msec() * 0.001) * 0.35
	else: wag = sin(OS.get_ticks_msec() * 0.014) * 1.0
	
	rot.rotation_degrees = des_rot
	swish.global_transform.origin = rot.global_transform.origin
	
	var add = Vector3(0.0, wag, 0.0)
	if sitting: add.x = 0.5
	if diving: add.x = 1.0
	
	swish.rotation.x = lerp_angle(swish.rotation.x, rot.global_rotation.x + add.x, 0.9)
	swish.rotation.y = lerp_angle(swish.rotation.y, rot.global_rotation.y + add.y, 0.15)
	swish.rotation.z = lerp_angle(swish.rotation.z, rot.global_rotation.z + add.z, 0.15)

func _load_tail(mesh, color):
	tail.mesh = mesh
	var mat = tail.material_override.duplicate()
	mat.albedo_color = color
	tail.material_override = mat
