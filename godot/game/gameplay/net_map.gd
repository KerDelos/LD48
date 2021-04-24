extends Node2D


var hovered_netn = null

var final_node = null


func _ready():
	for c in get_children():
		if c.is_final_node:
			final_node = c
		c.init_link_with_out_nodes()
		c.connect("netn_hovered", self, "on_netn_hovered")
		c.connect("netn_unhovered", self, "on_netn_unhovered")
		c.connect("open_shop",get_parent(),"open_shop")


func on_netn_hovered(netn):
	hovered_netn = netn
	
func on_netn_unhovered(netn):
	hovered_netn = null

func is_netn_hovered():
	return hovered_netn != null

func apply_flop_on_hovered_netn(flop_stat):
	return hovered_netn.receive_flop(flop_stat)

func is_final_node_acquired():
	return final_node.is_player_controlled
