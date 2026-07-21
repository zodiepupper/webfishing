extends Node2D

export var winning = false

var written_words = [
	"ZRO", 
	"ONE", 
	"TWO", 
	"THR", 
	"FOR", 
	"FIV", 
	"SIX", 
	"SVN", 
	"EGT", 
	"NIN", 
	"TEN", 
	"LVN", 
	"TLV", 
	"TTN", 
	"FTN", 
	"FFN", 
	"SXT", 
	"STN", 
	"ETT", 
	"NTN", 
	"TWY", 
	"TON", 
	"TWT", 
	"TWR", 
	"TWF", 
	"TWV", 
	"TWX", 
	"TWS", 
	"TWE", 
	"TWI", 
	"TRY", 
	"TRO", 
	"TRT", 
	"TRR", 
	"TFU", 
	"TRV", 
	"TRX", 
	"TRS", 
	"TRE", 
	"TRI", 
	"FTY", 
	"FTO", 
	"FTT", 
	"FTR", 
	"FTF", 
	"FTV", 
	"FTX", 
	"FTS", 
	"FTE", 
	"FTI", 
	"FFY", 
]
var saved_num = 0
var prize_amt = 0
var scratched = false

signal _scratched

func _setup(type):
	if winning:
		$Label3.visible = false
	else:
		var chance = 0.7
		var price = 0
		for i in 8:
			if randf() <= chance:
				price += 1
				chance *= 0.75
			else:
				break
		
		prize_amt = [10, 25, 50, 100, 200, 500, 1000, 5000, 10000][price]
		if type == 1: prize_amt = stepify(prize_amt * 2.5, 5)
		if type == 2: prize_amt = stepify(prize_amt * 10, 5)
		_set_price(prize_amt)

func _on_Area2D_body_exited(body):
	if not body.is_in_group("scratch_map") or scratched: return
	emit_signal("_scratched")
	scratched = true

func _set_number(num):
	saved_num = num
	$Label.text = str(num)
	$Label2.text = written_words[num]

func _set_price(val):
	$Label3.text = "$" + str(val)
	if val < 1000: $Label3.text = $Label3.text + ".00"

func _win_ping():
	$Label.set("custom_colors/font_color", Color("#a4aa39"))
	$Label2.set("custom_colors/font_color", Color("#a4aa39"))
	$Label3.set("custom_colors/font_color", Color("#a4aa39"))
	$stars.restart()
