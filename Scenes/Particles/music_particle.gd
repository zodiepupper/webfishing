extends Particles

func _ready():
	material_override = [
		preload("res://Assets/Materials/music_mat_a.tres"), 
		preload("res://Assets/Materials/music_mat_b.tres"), 
		preload("res://Assets/Materials/music_mat_c.tres"), 
		preload("res://Assets/Materials/music_mat_d.tres"), 
	][randi() % 4]
