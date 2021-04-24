tool

extends Node2D

enum netn_type {NONE, HOME, MISC, DATA}

var node_type_to_color = {
	netn_type.NONE: Color.red,
	netn_type.HOME: Color.green,
	netn_type.MISC: Color.gray,
	netn_type.DATA: Color.blue,
}

export (Array, NodePath) var out_nodes;
var in_nodes;

export (netn_type) var node_type;

export var is_player_controlled = false;


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	update()
	$Sprite.modulate = node_type_to_color[node_type];
	pass
	
func _draw():
	for o in out_nodes:
		draw_line(Vector2(0,0), get_node(o).position - self.position, Color.green if is_player_controlled else Color.red, 1)
	

