extends Position2D

var pistol_case = preload("res://bullet_case.tscn")
var shot_shell = preload("res://shell_case.tscn")

var curr_case


func _ready():
	pass # Replace with function body.

func eject(which):
	match which:
		"Thommy":
			var bullet = pistol_case.instance()
			add_child(bullet)
			bullet.get_node("body_case").apply_central_impulse(Vector2(0,-500))
		"Broomhandle":
			var bullet = pistol_case.instance()
			add_child(bullet)
			bullet.get_node("body_case").apply_central_impulse(Vector2(0,-500))
		"Trenchgun":
			var bullet = shot_shell.instance()
			add_child(bullet)
			bullet.get_node("body_case").apply_central_impulse(Vector2(0,-500))
		"Levergun":
			var bullet = pistol_case.instance()
			add_child(bullet)
			bullet.get_node("body_case").get_node("Sprite").scale.x *= 1.5
			bullet.get_node("body_case").get_node("Sprite").scale.y *= 2
			bullet.get_node("body_case").apply_central_impulse(Vector2(0,-500))
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
