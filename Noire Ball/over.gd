extends Node2D

var over_timer = 0
export var time_to_menu = 0
func _ready():
	pass 
	
func _process(delta):
	
	over_timer+=delta
	
	if over_timer >= time_to_menu:
		get_tree().change_scene("res://Menu.tscn")
