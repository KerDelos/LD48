extends Node2D

var floppy_scene = preload("floppy.tscn")

var junk_stat = preload("res://game/gameplay/floppys/flp_junk.tres");

export (Array, Resource)  var deck;

var draw_pile = []
var discard_pile = []

var hand = []
var selected_flop = null

var initial_hand_size = 2

export var initial_energy = 4
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
	$"../hud".set_energy(energy, initial_energy)
	
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
	if draw_pile.empty():
		discard_pile.shuffle()
		draw_pile.append_array(discard_pile)
		discard_pile.clear()
		
	var flop = floppy_scene.instance()
	add_child(flop)
	hand.append(flop)
	flop.init(draw_pile.pop_back())
	flop.connect("flop_selected",self,"on_floppy_selected")
	
	spray_hand()
	SoundManager.play_sfx(SoundManager.sfx_flop_draw)

func discard(flop, was_consumed, was_binned = false):
	hand.remove(hand.find(flop))
	if !was_binned:
		discard_pile.append(flop.stats)
	else :
		deck.remove(deck.find(flop.stats))
	if !was_consumed:
		consume_energy(flop.stats.discard_cost);
		SoundManager.play_sfx(SoundManager.sfx_flop_discard)
	flop.queue_free()
	spray_hand();

func spray_hand():
	if hand.empty():
		return;
	var i = 1
	var card_interval = 1.0/float(hand.size())
	for flop in hand:
		flop.position = lerp($Start.position,$End.position,(float(i)/hand.size())-(card_interval/2.0))
		i = i+1
	$"../hud".set_draw_pile(draw_pile.size())

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
	if netmap.is_netn_hovered() :
		if can_play_flop(floppy.stats):
			if netmap.can_apply_flop_on_hovered_netn(floppy.stats) :
				netmap.apply_flop_on_hovered_netn(floppy.stats)
				consume(floppy)
				main_scene().check_for_end()
		else:
			SoundManager.play_sfx(SoundManager.sfx_cant)
	elif discard_hovered:
		discard(floppy,false)
		main_scene().check_for_end()

func consume(floppy):
	consume_energy(floppy.stats.cost)
	discard(floppy,true)

func consume_energy(conso):
	energy = energy - conso;
	$"../hud".set_energy(energy, initial_energy)

func can_play_flop(stats):
	return energy >= stats.cost

func can_player_continue():
	return energy > 0

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
	while hand.size() < initial_hand_size:
		draw()

func discard_hovered():
	discard_hovered = true;
	$Discard/SpriteHolder.scale = Vector2(1.1,1.1)
	SoundManager.play_sfx(SoundManager.sfx_hover)
	$Discard/SpriteHolder/Label.visible = true;
	
func discard_unhovered():
	discard_hovered = false;
	$Discard/SpriteHolder.scale = Vector2(1.0,1.0)
	$Discard/SpriteHolder/Label.visible = false;

func draw_flops(nb):
	for i in range(0,nb):
		draw()

func _on_Discard_mouse_entered():
	discard_hovered()

func _on_Discard_mouse_exited():
	discard_unhovered()

func enemy_attack():
	acquire_flop(junk_stat)

func firewall_attack():
	dont_draw_next = true
