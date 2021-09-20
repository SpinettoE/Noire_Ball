extends Node2D

export var action_required_app = ""
export var action_required_dis = "dash"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_just_pressed(action_required_dis):
		queue_free()
	if Input.is_action_just_pressed(action_required_app):
		visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
