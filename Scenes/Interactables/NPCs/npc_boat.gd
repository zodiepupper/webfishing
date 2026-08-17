extends Node3D

func _on_npc_boat__open(): $AnimationPlayer.play("Open")
func _on_npc_boat__close(): $AnimationPlayer.play_backwards("Open")

func _ready():
	$face_anim.play("idle")
func _physics_process(delta):
	$AnimatedSprite3D.position.y = 2.765 + (sin(Time.get_ticks_msec() * 0.002) * 0.01)

