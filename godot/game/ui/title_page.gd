extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_ExitDetect_mouse_entered():
	$ExitHigh.visible = true


func _on_ExitDetect_mouse_exited():
	$ExitHigh.visible = false


func _on_ExitDetect_pressed():
	get_tree().quit()


func _on_PlayDetect_mouse_entered():
	$PlayHigh.visible = true


func _on_PlayDetect_mouse_exited():
	$PlayHigh.visible = false


func _on_PlayDetect_pressed():
	get_tree().change_scene("res://game/main_scene.tscn")
