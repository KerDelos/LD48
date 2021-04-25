#tool

extends Node2D

signal netn_hovered(netn)
signal netn_unhovered(netn)
signal open_shop(shop_content)
signal new_home(home)
signal energy_bonus(amount)
signal bin()


enum netn_type {NONE, HOME, MISC, DATA, ENERGY, ENEMY, FIREWALL}
enum netn_state {NONE, NEUTRAL, PLAYER, HERE}


var sprites ={
	netn_type.HOME :{
		netn_state.NONE : [ preload("res://resources/gameplay/home_neutral_low.png"), preload("res://resources/gameplay/home_neutral_high.png")],
		netn_state.NEUTRAL : [ preload("res://resources/gameplay/home_neutral_low.png"), preload("res://resources/gameplay/home_neutral_high.png")],
		netn_state.PLAYER : [ preload("res://resources/gameplay/home_here_low.png"), preload("res://resources/gameplay/home_here_high.png")],
		netn_state.HERE : [ preload("res://resources/gameplay/home_player_low.png"), preload("res://resources/gameplay/home_player_high.png")],
	},
	netn_type.MISC :{
		netn_state.NONE : [ preload("res://resources/gameplay/unknown_neutral_low.png"), preload("res://resources/gameplay/unknown_neutral_high.png")],
		netn_state.NEUTRAL : [ preload("res://resources/gameplay/node_neutral_low.png"), preload("res://resources/gameplay/node_neutral_high.png")],
		netn_state.PLAYER : [ preload("res://resources/gameplay/node_here_low.png"), preload("res://resources/gameplay/node_here_high.png")],
		netn_state.HERE : [ preload("res://resources/gameplay/node_player_low.png"), preload("res://resources/gameplay/node_player_high.png")],
	},
	netn_type.DATA :{
		netn_state.NONE : [ preload("res://resources/gameplay/unknown_neutral_low.png"), preload("res://resources/gameplay/unknown_neutral_high.png")],
		netn_state.NEUTRAL : [ preload("res://resources/gameplay/data_neutral_low.png"), preload("res://resources/gameplay/data_neutral_high.png")],
		netn_state.PLAYER : [ preload("res://resources/gameplay/data_here_low.png"), preload("res://resources/gameplay/data_here_high.png")],
		netn_state.HERE : [ preload("res://resources/gameplay/data_player_low.png"), preload("res://resources/gameplay/data_player_high.png")],
	},
	netn_type.ENERGY :{
		netn_state.NONE : [ preload("res://resources/gameplay/unknown_neutral_low.png"), preload("res://resources/gameplay/unknown_neutral_high.png")],
		netn_state.NEUTRAL : [ preload("res://resources/gameplay/cpu_neutral_low.png"), preload("res://resources/gameplay/cpu_neutral_high.png")],
		netn_state.PLAYER : [ preload("res://resources/gameplay/cpu_here_low.png"), preload("res://resources/gameplay/cpu_here_high.png")],
		netn_state.HERE : [ preload("res://resources/gameplay/cpu_player_low.png"), preload("res://resources/gameplay/cpu_player_high.png")],
	},
	netn_type.ENEMY :{
		netn_state.NONE : [ preload("res://resources/gameplay/unknown_neutral_low.png"), preload("res://resources/gameplay/unknown_neutral_high.png")],
		netn_state.NEUTRAL : [ preload("res://resources/gameplay/node_enemy_low.png"), preload("res://resources/gameplay/node_enemy_high.png")],
		netn_state.PLAYER : [ preload("res://resources/gameplay/node_here_low.png"), preload("res://resources/gameplay/node_here_high.png")],
		netn_state.HERE : [ preload("res://resources/gameplay/node_player_low.png"), preload("res://resources/gameplay/node_player_high.png")],
	},
	netn_type.FIREWALL :{
		netn_state.NONE : [ preload("res://resources/gameplay/unknown_neutral_low.png"), preload("res://resources/gameplay/unknown_neutral_high.png")],
		netn_state.NEUTRAL : [ preload("res://resources/gameplay/wall_neutral_low.png"), preload("res://resources/gameplay/wall_neutral_high.png")],
		netn_state.PLAYER : [ preload("res://resources/gameplay/wall_here_low.png"), preload("res://resources/gameplay/wall_here_high.png")],
		netn_state.HERE : [ preload("res://resources/gameplay/wall_player_low.png"), preload("res://resources/gameplay/wall_player_high.png")],
	},
}

export (Array, NodePath) var out_nodes;
var in_nodes = [];
var connected_nodes = []

var is_hovered = false;

export var is_final_node = false;
export (netn_type) var node_type;

export var player_start = false;

var current_state = netn_state.NONE;

export (Array, Resource) var shop_content;

func is_accessible_by_player():
	for n in connected_nodes:
		if n.current_state == netn_state.HERE:
			return true
	return false

func is_player_here():
	return current_state == netn_state.HERE

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func init():
	for o in out_nodes:
		connected_nodes.append(get_node(o))
	refresh_sprite();


func _process(delta):
	update()
	pass
	
func _draw():
	#todo comment that when not level designing
	for o in out_nodes:
		draw_line(Vector2(0,0), get_node(o).position - self.position, Color.green if current_state == netn_state.HERE or get_node(o).current_state == netn_state.HERE else Color.red, 1)
	
	for o in connected_nodes:
		draw_line(Vector2(0,0), o.position - self.position, Color.green if current_state == netn_state.HERE or o.current_state == netn_state.HERE else Color.red, 1)

func init_link_with_out_nodes():
	for o in out_nodes:
		var out_node = get_node(o);
		out_node.in_nodes.append(self);
		out_node.connected_nodes.append(self);

func acquired_by_player():
	current_state = netn_state.HERE
	for netn in connected_nodes:
		if netn.current_state == netn_state.NONE:
			netn.current_state = netn_state.NEUTRAL;
		elif netn.current_state == netn_state.HERE:
			netn.current_state = netn_state.PLAYER
		netn.refresh_sprite()
	refresh_sprite();
	on_acquired_by_player();
		
func on_acquired_by_player():
	if node_type == netn_type.DATA:
		emit_signal("open_shop", shop_content)
	elif node_type == netn_type.HOME:
		emit_signal("new_home", self)
	elif node_type == netn_type.ENERGY:
		emit_signal("energy_bonus", 1)
	elif node_type == netn_type.MISC:
		pass

func _on_Area2D_mouse_entered():
	is_hovered = true;
	refresh_sprite()
	emit_signal("netn_hovered",self)

func _on_Area2D_mouse_exited():
	is_hovered = false;
	refresh_sprite()
	emit_signal("netn_unhovered",self)

func receive_flop(flop_stat):
	acquired_by_player()
	return true;

	
func can_receive_flop(flop_stat):
	#todo this is innacurate, it needs to change depending on the floppy
	if is_accessible_by_player() and current_state != netn_state.HERE:
		return true;
	return false

func refresh_sprite():
	if sprites.has(node_type):
		var sprite_set = sprites[node_type]
		$Sprite.texture = sprite_set[current_state][1] if is_hovered else sprite_set[current_state][0];
