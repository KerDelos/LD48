extends Node2D


var hovered_netn = null


func _ready():
	for c in get_children():
		c.connect("netn_hovered", self, "on_netn_hovered")
		c.connect("netn_unhovered", self, "on_netn_unhovered")


func on_netn_hovered(netn):
	hovered_netn = netn
	
func on_netn_unhovered(netn):
	hovered_netn = null

func is_netn_hovered():
	return hovered_netn != null

func apply_flop_on_hovered_netn(flop_stat):
	return hovered_netn.receive_flop(flop_stat)
