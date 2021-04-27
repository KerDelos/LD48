extends Node2D


var hovered_netn = null

var final_node = null


func _ready():
	var p_start = null
	for c in get_children():
		if c is VisibilityNotifier2D or c is TileMap or c is Sprite:
			continue
		if c.is_final_node:
			final_node = c
		if c.player_start:
			p_start = c
		c.init()
		c.init_link_with_out_nodes()
		c.connect("netn_hovered", self, "on_netn_hovered")
		c.connect("netn_unhovered", self, "on_netn_unhovered")
		c.connect("open_shop",get_parent(),"open_shop")
		c.connect("new_home",get_parent(),"new_home")
		c.connect("energy_bonus",get_parent(),"energy_bonus")
		c.connect("firewall_attack",get_parent(),"firewall_attack")
		c.connect("enemy_attack",get_parent(), "enemy_attack")
		c.connect("draw_flops", get_parent(),"draw_flops")
	p_start.reveal_name()
	p_start.acquired_by_player()

func is_netn_hovered():
	return hovered_netn != null

func on_netn_hovered(netn):
	hovered_netn = netn
	
func on_netn_unhovered(netn):
	hovered_netn = null

func can_apply_flop_on_hovered_netn(flop_stat):
	return hovered_netn.can_receive_flop(flop_stat)

func apply_flop_on_hovered_netn(flop_stat):
	return hovered_netn.receive_flop(flop_stat)

func is_final_node_acquired():
	return final_node.is_player_here()
