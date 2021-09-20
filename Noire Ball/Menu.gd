extends Node2D


func _ready():
	pass # Replace with function body.


func _on_Play_pressed():
	get_tree().change_scene("res://Assets/Levels/level_"+str(GlobalHandler.level)+".tscn")


func _on_Credits_pressed():
	get_tree().change_scene("res://credits.tscn")

func _on_Exit_pressed():
	get_tree().quit()
