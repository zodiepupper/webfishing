extends Spatial

func _on_npc_boat__open(): $AnimationPlayer.play("Open")
func _on_npc_boat__close(): $AnimationPlayer.play_backwards("Open")

func _ready():
	$face_anim.play("idle")
func _physics_process(delta):
	$AnimatedSprite3D.translation.y = 2.765 + (sin(OS.get_ticks_msec() * 0.002) * 0.01)

