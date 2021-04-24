extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func init(is_victory, stats):
	$HBoxContainer/Label.text = "Congratulations" if is_victory else "Try again";
	#$HBoxContainer/Label2.text = stats....;

func _on_ButtonRestart_pressed():
	get_tree().change_scene("res://game/main_scene.tscn")


func _on_ButtonReturn_pressed():
	get_tree().change_scene("res://game/ui/title_page.tscn")
