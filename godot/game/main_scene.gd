extends Control

var end_menu = preload("res://game/ui/end_menu.tscn")
var shop_menu = preload("res://game/ui/shop.tscn")

var shop_instance = null

func _ready():
	pass # Replace with function body.

func _process(_event):
	var camera_vec = Vector2(0,0)
	if Input.is_action_pressed("ui_up"):
		camera_vec.y -= 1
	if Input.is_action_pressed("ui_down"):
		camera_vec.y += 1
	if Input.is_action_pressed("ui_left"):
		camera_vec.x -= 1
	if Input.is_action_pressed("ui_right"):
		camera_vec.x += 1
		
	if $netmap/UpDetect.is_on_screen() && camera_vec.y < 0:
		camera_vec.y = 0
	if $netmap/DownDetect.is_on_screen() && camera_vec.y > 0:
		camera_vec.y = 0
	if $netmap/LeftDetect.is_on_screen() && camera_vec.x < 0:
		camera_vec.x = 0
	if $netmap/RightDetect.is_on_screen() && camera_vec.x > 0:
		camera_vec.x = 0
			
	$Camera2D.position = $Camera2D.position + camera_vec*5

func check_for_end():
	if shop_instance != null:
		return
	if $netmap.is_final_node_acquired() :
		var menu = end_menu.instance()
		$CanvasLayer.menu.init(true,null)
		add_child(menu)
	elif !deck().can_player_continue():
		var menu = end_menu.instance()
		menu.init(false,null)
		$CanvasLayer.add_child(menu)
	elif shop_instance == null:
		deck().start_next_turn()

func open_shop(content):
	shop_instance = shop_menu.instance()
	shop_instance.init(content)
	$CanvasLayer.add_child(shop_instance)
	shop_instance.connect("flop_acquired",deck(),"acquire_flop")
	shop_instance.connect("shop_closed",self,"shop_closed")
	
func shop_closed():
	shop_instance = null
	check_for_end()

func deck():
	return $CanvasLayer/deck
func new_home(home):
	deck().new_home()

func energy_bonus(amount):
	deck().energy_bonus(amount)
	
func enemy_attack():
	deck().enemy_attack()

func firewall_attack():
	deck().firewall_attack()

func center_camera_on_node(netn):
	$Camera2D.position = netn.position

func draw_flops(nb):
	deck().draw_flops(nb);

func bin():
	deck().bin()
