extends Control

var end_menu = preload("res://game/ui/end_menu.tscn")
var shop_menu = preload("res://game/ui/shop.tscn")

var shop_instance = null

func _ready():
	pass # Replace with function body.

func check_for_end():
	if shop_instance != null:
		return
	if $netmap.is_final_node_acquired() :
		var menu = end_menu.instance()
		menu.init(true,null)
		add_child(menu)
	elif !$deck.can_player_continue():
		var menu = end_menu.instance()
		menu.init(false,null)
		add_child(menu)
	elif shop_instance == null:
		$deck.start_next_turn()

func open_shop(content):
	shop_instance = shop_menu.instance()
	shop_instance.init(content)
	add_child(shop_instance)
	shop_instance.connect("flop_acquired",$deck,"acquire_flop")
	shop_instance.connect("shop_closed",self,"shop_closed")
	
func shop_closed():
	shop_instance = null
	check_for_end()

func new_home(home):
	$deck.new_home()

func energy_bonus(amount):
	$deck.energy_bonus(amount)
