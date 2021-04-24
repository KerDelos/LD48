extends Node2D

var floppy_scene = preload("floppy.tscn")

export (Array, Resource)  var deck;

var hand = []
var selected_flop = null

# Called when the node enters the scene tree for the first time.
func _ready():
	init_hand()
	spray_hand()
	
func clear_hand():
	hand.clear()


func init_hand():
	clear_hand();
	for card in deck:
		var flop = floppy_scene.instance()
		add_child(flop)
		hand.append(flop)
		flop.init(card)
		flop.connect("flop_selected",self,"on_floppy_selected")
		flop.connect("flop_hovered",self,"on_flop_hovered")
		flop.connect("flop_unhovered",self,"on_flop_unhovered")

func spray_hand():
	var i = 0
	for flop in hand:
		var pos = lerp($Start.position,$End.position,float(i)/hand.size())
		flop.position = lerp($Start.position,$End.position,float(i)/hand.size())
		flop.rotation_degrees = lerp($Start.rotation_degrees,$End.rotation_degrees,float(i)/hand.size())
		i = i+1

func _input(event):
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and !event.is_pressed():
		floppy_released(selected_flop)

func on_flop_hovered(floppy):
	floppy.z_index = 2
	pass
	
func on_flop_unhovered(floppy):
	floppy.z_index = 0
	pass
	
func on_floppy_selected(floppy):
	selected_flop = floppy
	floppy.select()

func floppy_released(floppy):
	floppy.unselect()
	selected_flop = null
	var netmap = $"../netmap"
	var result = false;
	if netmap.is_netn_hovered():
		result = netmap.apply_flop_on_hovered_netn(floppy.stats)
