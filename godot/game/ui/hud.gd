extends Control
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(energy_level,total, draw_pile):
	set_energy(energy_level,total)
	
func set_energy(energy,total):
	$NinePatchRect/VBoxContainer/HBoxContainer/EnergyCount.text = str(energy)
	$NinePatchRect/VBoxContainer/HBoxContainer/EnergyTotal.text = str(total)

func set_draw_pile(nb):
	$NinePatchRect/VBoxContainer/HBoxContainer2/DrawCount.text = str(nb)
