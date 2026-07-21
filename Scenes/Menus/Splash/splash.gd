extends Control

onready var menu_load = preload("res://Scenes/Menus/Main Menu/main_menu.tscn")


var load_progress = 0
var load_total = 0

var time = 0
var loaded = false

func _ready():
	yield(get_tree().create_timer(0.2), "timeout")
	
	
	var particles = []
	
	print("Loading Particles for Preloading...")
	var dir = Directory.new()
	var path = "res://Assets/ParticleResources/"
	
	if dir.open(path) != OK:
		print("Error loading particle directory.")
		return
	dir.list_dir_begin(true, true)
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif file.ends_with(".tres"):
			particles.append(path + file)
	
	print("Particles Obtained")
	
	load_total = particles.size()
	$ProgressBar.max_value = load_total
	
	for particle in particles:
		yield(get_tree(), "idle_frame")
		var instance = Particles.new()
		instance.set_process_material(load(particle))
		instance.one_shot = true
		instance.emitting = true
		add_child(instance)
		load_progress += 1
		$ProgressBar.value = load_progress
	
	yield(get_tree().create_timer(0.5), "timeout")
	loaded = true
	$ProgressBar.hide()
	$AnimationPlayer.play("main")

func _physics_process(delta):
	time += 1
	if Input.is_action_just_pressed("primary_action") and time > 60 and loaded:
		_on_AnimationPlayer_animation_finished("n/a")

func _on_AnimationPlayer_animation_finished(anim_name):
	$lame.visible = false
	$god.visible = false
	SceneTransition._change_scene("res://Scenes/Menus/Main Menu/main_menu.tscn", 0.9, false)
