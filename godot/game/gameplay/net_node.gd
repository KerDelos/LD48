#tool

extends Node2D

signal netn_hovered(netn)
signal netn_unhovered(netn)


enum netn_type {NONE, HOME, MISC, DATA}

var node_type_to_color = {
	netn_type.NONE: Color.darkred,
	netn_type.HOME: Color.darkgreen,
	netn_type.MISC: Color.gray,
	netn_type.DATA: Color.darkblue,
}

export (Array, NodePath) var out_nodes;
var in_nodes;

export (netn_type) var node_type;

export var is_player_controlled = false;
var is_player_accessible = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.modulate = node_type_to_color[node_type];
	if is_player_controlled:
		acquired_by_player()

func _process(delta):
	update()
	pass
	
func _draw():
	for o in out_nodes:
		draw_line(Vector2(0,0), get_node(o).position - self.position, Color.green if is_player_controlled else Color.red, 1)


func acquired_by_player():
	is_player_controlled = true;
	for o in out_nodes:
		var out_node = get_node(o);
		out_node.is_player_accessible = true;

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
