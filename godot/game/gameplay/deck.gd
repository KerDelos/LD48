extends Node2D

var floppy_scene = preload("floppy.tscn")

var junk_stat = preload("res://game/gameplay/floppys/flp_junk.tres");

export (Array, Resource)  var deck;

var draw_pile = []
var discard_pile = []

var hand = []
var selected_flop = null

var initial_hand_size = 2

var initial_energy = 4
var energy;


var discard_hovered = false;
var dont_draw_next = false;

func netmap():
	return $"../../netmap"
func main_scene():
	return $"../.."

# Called when the node enters the scene tree for the first time.
func _ready():
	shuffle_deck_into_draw_pile()
	reset_energy()
	init_hand()
	spray_hand()
	
func _process(delta):
	update();
	

func _draw():
	if selected_flop != null:
		var draw_color = Color.gray
		var netmap = netmap()
		if netmap.is_netn_hovered():
			draw_color = Color.green if netmap.can_apply_flop_on_hovered_netn(selected_flop.stats) else Color.red
		draw_line(selected_flop.position, get_local_mouse_position(), draw_color, 2)
	

func reset_energy():
	energy = initial_energy;
	$"../hud".set_energy(energy)
	
func shuffle_deck_into_draw_pile():
	for card in deck:
		draw_pile.append(card)
	draw_pile.shuffle()

func clear_hand():
	for flop in hand:
		flop.queue_free()
	hand.clear()

func init_hand():
	clear_hand();
	for i in range(0,initial_hand_size):
		draw()

func new_home():
	draw_pile.clear()
	discard_pile.clear()
	reset_energy()
	shuffle_deck_into_draw_pile()
	init_hand()
	pass
	
func draw():
	if !draw_pile.empty():
		var flop = floppy_scene.instance()
		add_child(flop)
		hand.append(flop)
		flop.init(draw_pile.pop_back())
		flop.connect("flop_selected",self,"on_floppy_selected")
	spray_hand()

func discard(flop, was_consumed, was_binned = false):
	hand.remove(hand.find(flop))
	if !was_binned:
		discard_pile.append(flop.stats)
	else :
		deck.remove(deck.find(flop.stats))
	if !was_consumed:
		consume_energy(flop.stats.discard_cost);
	flop.queue_free()

func spray_hand():
	var i = 0
	for flop in hand:
		var pos = lerp($Start.position,$End.position,float(i)/hand.size())
		flop.position = lerp($Start.position,$End.position,float(i)/hand.size())
		i = i+1

func _input(event):
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and !event.is_pressed():
		floppy_released(selected_flop)
	
func on_floppy_selected(floppy):
	selected_flop = floppy
	floppy.select()

func floppy_released(floppy):
	if floppy == null:
		return
	floppy.unselect()
	selected_flop = null
	var netmap = netmap()
	if netmap.is_netn_hovered() and can_play_flop(floppy.stats):
		if netmap.can_apply_flop_on_hovered_netn(floppy.stats) :
			netmap.apply_flop_on_hovered_netn(floppy.stats)
			consume(floppy)
			main_scene().check_for_end()
	elif discard_hovered:
		discard(floppy,false)
		main_scene().check_for_end()

func consume(floppy):
	consume_energy(floppy.stats.cost)
	discard(floppy,true)

func consume_energy(conso):
	energy = energy - conso;
	$"../hud".set_energy(energy)

func can_play_flop(stats):
	return energy >= stats.cost

func can_player_continue():
	return (!hand.empty() or !draw_pile.empty() ) and energy > 0
	#todo actually we should check if there is enough energy to play one of the remaining card

func acquire_flop(stat):
	deck.append(stat)
	draw_pile.append(stat)
	print("got a new card")

func energy_bonus(amount):
	initial_energy = initial_energy+1
	consume_energy(-1)

func start_next_turn():
	if dont_draw_next:
		dont_draw_next = false
		return;
	while !draw_pile.empty() and hand.size() < initial_hand_size:
		draw()

func discard_hovered():
	discard_hovered = true;
	$Discard/SpriteHolder.scale = Vector2(1.1,1.1)
	
func discard_unhovered():
	discard_hovered = false;
	$Discard/SpriteHolder.scale = Vector2(1.0,1.0)


func _on_Discard_mouse_entered():
	discard_hovered()

func _on_Discard_mouse_exited():
	discard_unhovered()

func enemy_attack():
	acquire_flop(junk_stat)

func firewall_attack():
	dont_draw_next = true
