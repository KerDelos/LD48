tool

extends Node2D

signal netn_hovered(netn)
signal netn_unhovered(netn)
signal open_shop(shop_content)
signal new_home(home)
signal energy_bonus(amount)
signal firewall_attack()
signal enemy_attack()
signal draw_flops(nb)


export var crop_distance = 1

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

export (String) var netn_name = "###";

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

func reveal_name():
	$NameLabel.text = "# " + netn_name + " #"

func init():
	for o in out_nodes:
		connected_nodes.append(get_node(o))
	if node_type == netn_type.HOME:
		current_state = netn_state.NEUTRAL
	refresh_sprite();
	$NameLabel.text = "# ??? #"


func _process(delta):
	update()
	pass
	
func _draw():
	if Engine.editor_hint:
		var guide_color = Color(0.4,0.4,0.4)
		var guide_size = 50
		draw_line(Vector2(0,0), Vector2(2.0,1.0)*guide_size, guide_color, 1)
		draw_line(Vector2(0,0), Vector2(-2.0,1.0)*guide_size, guide_color, 1)
		draw_line(Vector2(0,0), Vector2(-2.0,-1.0)*guide_size, guide_color, 1)
		draw_line(Vector2(0,0), Vector2(2.0,-1.0)*guide_size, guide_color, 1)
		for o in out_nodes:
			var other = get_node(o).position - self.position
			var unit = other.normalized()
			draw_line(Vector2(0,0)+unit*crop_distance, other-unit*crop_distance, Color.green, 1)
		$NameLabel.text = "# " + netn_name + " #"
		refresh_sprite(true)
	
	for o in connected_nodes:
		var other = o.position - self.position
		var unit = other.normalized()
		draw_line(Vector2(0,0)+unit*crop_distance, other-unit*crop_distance, Color.green if current_state == netn_state.HERE or o.current_state == netn_state.HERE else Color.white, 1)

func init_link_with_out_nodes():
	for o in out_nodes:
		var out_node = get_node(o);
		out_node.in_nodes.append(self);
		out_node.connected_nodes.append(self);

func acquired_by_player():
	var old_state = current_state
	current_state = netn_state.HERE
	for netn in connected_nodes:
		if netn.current_state == netn_state.NONE:
			netn.current_state = netn_state.NEUTRAL;
		elif netn.current_state == netn_state.HERE:
			netn.current_state = netn_state.PLAYER
		netn.refresh_sprite()
	refresh_sprite();
	if old_state != netn_state.PLAYER:
		on_acquired_by_player();
		SoundManager.play_sfx(SoundManager.sfx_acquire)

func scan_adjacent_nodes():
	for netn in connected_nodes:
		if netn.current_state == netn_state.NONE:
			netn.current_state = netn_state.NEUTRAL;
		netn.refresh_sprite()

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
	SoundManager.play_sfx(SoundManager.sfx_hover)
	$NameLabel.visible = true;
	$HereLabel.visible = false

func _on_Area2D_mouse_exited():
	is_hovered = false;
	refresh_sprite()
	emit_signal("netn_unhovered",self)
	$NameLabel.visible = false;
	$HereLabel.visible = current_state == netn_state.HERE

func receive_flop(flop_stat):
	if flop_stat.ram > 0:
		emit_signal("draw_flops", flop_stat.ram)
	elif flop_stat.scan > 0:
		scan_adjacent_nodes();
	elif node_type == netn_type.FIREWALL :
		if flop_stat.breach <= 0:
			emit_signal("firewall_attack")
		acquired_by_player()
	elif node_type == netn_type.ENEMY :
		if flop_stat.attack <= 0:
			emit_signal("enemy_attack")
		acquired_by_player()
	else:
		acquired_by_player()
	return true;

	
func can_receive_flop(flop_stat):
	if flop_stat.scan > 0:
		return current_state != netn_state.NONE and node_type != netn_type.HOME
	if flop_stat.move > 0 or flop_stat.attack > 0:
		return is_accessible_by_player() and current_state != netn_state.HERE
	elif flop_stat.breach > 0:
		return is_accessible_by_player() and current_state != netn_state.HERE \
		and current_state != netn_state.PLAYER and node_type == netn_type.FIREWALL
	elif flop_stat.ram > 0:
		return current_state == netn_state.HERE
	else:
		return false

func refresh_sprite(editor_display = false):
	if sprites.has(node_type):
		var sprite_set = sprites[node_type]
		var sprite_state = current_state if !editor_display else netn_state.NEUTRAL
		$Sprite.texture = sprite_set[sprite_state][1] if is_hovered else sprite_set[sprite_state][0];
	$NameLabel.visible = false;
	$HereLabel.visible = current_state == netn_state.HERE
	
	if current_state == netn_state.NEUTRAL:
		reveal_name()
		
	if editor_display:
		$NameLabel.visible = true;
