extends Node2D


signal flop_selected (flop)
signal flop_hovered (flop)
signal flop_unhovered (flop)

var stats = null

var is_selected= false;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func init(flop_stats):
	stats = flop_stats
	$Visual.init(stats)

func _on_Area2D_mouse_entered():
	scale = Vector2(1.2,1.2);
	emit_signal("flop_hovered", self)
	

func _on_Area2D_mouse_exited():
	if !is_selected:
		scale = Vector2(1.0,1.0);
	emit_signal("flop_unhovered", self)

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.is_pressed():
		emit_signal("flop_selected",self);

func select():
	scale = Vector2(1.2,1.2);
	is_selected = true;
	
func unselect():
	scale = Vector2(1.0,1.0);
	is_selected= false;
