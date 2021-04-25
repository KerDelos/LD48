extends Control

var floppy_visual = preload("res://game/gameplay/floppy_visual.tscn")

var content = null

signal flop_acquired(stats)
signal shop_closed()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(stats_list):
	content = stats_list
	var i = 0
	var card_pos = [$Panel/card1,$Panel/card2,$Panel/card3]
	for s in stats_list:
		var visu = floppy_visual.instance()
		visu.init(s)
		card_pos[i].add_child(visu)
		i = i+1


func _on_SkipButton_pressed():
	emit_signal("shop_closed")	
	queue_free()


func _on_card1_pressed():
	acquire_flop(content[0])


func _on_card2_pressed():
	acquire_flop(content[1])


func _on_card3_pressed():
	acquire_flop(content[2])

func acquire_flop(flop_stats):
	emit_signal("flop_acquired",flop_stats)
	emit_signal("shop_closed")
	queue_free()
