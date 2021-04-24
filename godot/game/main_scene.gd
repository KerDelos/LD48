extends Control

var end_menu = preload("res://game/ui/end_menu.tscn")

func _ready():
	pass # Replace with function body.

func check_for_end():
	if $netmap.is_final_node_acquired() :
		var menu = end_menu.instance()
		menu.init(true,null)
		add_child(menu)
	elif !$deck.can_player_continue():
		var menu = end_menu.instance()
		menu.init(false,null)
		add_child(menu)
	else:
		pass
