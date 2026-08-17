extends Sprite3D

func _ready():
	PlayerData.connect("_quest_update", Callable(self, "_quest_update"))
	_quest_update()

func _quest_update():
	var show = false
	for q in PlayerData.current_quests.keys():
		if PlayerData.current_quests[q].progress >= PlayerData.current_quests[q].goal_amt:
			show = true
			break
	visible = show

func _physics_process(delta):
	offset.y = sin(Time.get_ticks_msec() * 0.005) * 6
