extends Sprite

var visible_timer = 0
func _ready():
	visible = false
	pass # Replace with function body.

func _process(delta):
	if visible:
		visible_timer += delta
		if visible_timer >= 2:
			visible = false
			visible_timer = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
