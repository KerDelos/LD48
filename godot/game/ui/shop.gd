extends Control

var floppy_visual = preload("res://game/gameplay/floppy_visual.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(stats_list):
	for s in stats_list:
		var visu = floppy_visual.instance()
		visu.init(s)
		$Panel/HBoxContainer.add_child(visu)


func _on_SkipButton_pressed():
	queue_free()
