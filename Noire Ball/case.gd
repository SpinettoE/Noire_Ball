extends Node2D

var timer = 0
var snd_timer = 0
var random = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	random.randomize()
	
	$body_case.add_torque(random.randi_range(-250,250))


func _process(delta):
	timer += delta

	
	snd_timer -= delta
	if snd_timer < 0:
		snd_timer = 0
		
		
	if timer >= 2:
		queue_free()

