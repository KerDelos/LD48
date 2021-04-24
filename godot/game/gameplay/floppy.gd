extends Node2D


signal flop_selected (flop)
signal flop_hovered (flop)
signal flop_unhovered (flop)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func init(stats):
	pass

func _on_Panel_mouse_entered():
	scale = Vector2(1.2,1.2);
	emit_signal("flop_hovered", self)
	

func _on_Panel_mouse_exited():
	scale = Vector2(1.0,1.0);
	emit_signal("flop_unhovered", self)

func _on_Panel_gui_input(event):
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.is_pressed():
		emit_signal("flop_selected",self);
