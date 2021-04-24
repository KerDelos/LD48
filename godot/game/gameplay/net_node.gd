#tool

extends Node2D

signal netn_hovered(netn)
signal netn_unhovered(netn)
signal open_shop(shop_content)


enum netn_type {NONE, HOME, MISC, DATA}

var node_type_to_color = {
	netn_type.NONE: Color.darkred,
	netn_type.HOME: Color.darkgreen,
	netn_type.MISC: Color.gray,
	netn_type.DATA: Color.darkblue,
}

export (Array, NodePath) var out_nodes;
var in_nodes = [];
var connected_nodes = []


export var is_final_node = false;
export (netn_type) var node_type;

export var is_player_controlled = false;
var is_player_accessible = false;

export (Array, Resource) var shop_content;

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.modulate = node_type_to_color[node_type];
	for o in out_nodes:
		connected_nodes.append(get_node(o))
	if is_player_controlled:
		acquired_by_player()
	

func _process(delta):
	update()
	pass
	
func _draw():
	for o in connected_nodes:
		draw_line(Vector2(0,0), o.position - self.position, Color.green if is_player_controlled or o.is_player_controlled else Color.red, 1)

func init_link_with_out_nodes():
	for o in out_nodes:
		var out_node = get_node(o);
		out_node.in_nodes.append(self);
		out_node.connected_nodes.append(self);

func acquired_by_player():
	is_player_controlled = true;
	for netn in connected_nodes:
		netn.is_player_accessible = true;
	on_acquired_by_player();
		
func on_acquired_by_player():
	if node_type == netn_type.DATA:
		emit_signal("open_shop", shop_content)

func _on_Area2D_mouse_entered():
	modulate = node_type_to_color[node_type].lightened(1.0)
	emit_signal("netn_hovered",self)


func _on_Area2D_mouse_exited():
	modulate = node_type_to_color[node_type]
	emit_signal("netn_unhovered",self)

func receive_flop(flop_stat):
	if is_player_accessible and not is_player_controlled:
		acquired_by_player()
		return true;
	return false
