extends Node


export (Texture) var NeutralTexture;
export (Texture) var HoveredTexture;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(stat):
	$Title.text = stat.name
	$Label.text = stat.description
	
 
func hover():
	self.texture = HoveredTexture 
	
func unhover():
	self.texture = NeutralTexture
