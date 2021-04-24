extends Node2D

var floppy_scene = preload("floppy.tscn")

export (Array, Resource)  var deck;

var hand = []

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

func spray_hand():
	var i = 0
	for flop in hand:
		var pos = lerp($Start.position,$End.position,float(i)/hand.size())
		flop.position = lerp($Start.position,$End.position,float(i)/hand.size())
		flop.rotation_degrees = lerp($Start.rotation_degrees,$End.rotation_degrees,float(i)/hand.size())
		i = i+1
		
