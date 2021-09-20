extends Node2D

var enemy_0 = preload ("res://enemy_0.tscn")

var rng =  RandomNumberGenerator.new()
var player
var enemigos = []

var next_level_timer = 0
var spawn_timer = 0
var wave = 0
var bosses = 0
var max_boss_on_screen= 0
var max_enemies

export var weapon_upgrade_level = false
export var remaining = 0
export var boss_chance = 0
export var weapons = ["Revy"]
export var dummy_generator = false
export var force_one_boss = false

export var spawn_rate = 0
export var spawn_limit = 0
export var enable = true

var made = 0
var killed = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_node("hero")
	player.get_node("HUD/remaining2").max_value = remaining
	player.get_node("HUD/remaining2").value = remaining
	rng.randomize()
	max_enemies = remaining
	pass # Replace with function body.

func debug_add():
	if Input.is_action_just_pressed("spawn"):
		add_one()
	pass

func _process(delta):
	if !enable:
		return
		
	if remaining == 0:
		next_level_timer+=delta
		
	if next_level_timer >= 3:
		GlobalHandler.level+=1
		if ResourceLoader.exists("res://Assets/Levels/level_"+str(GlobalHandler.level)+".tscn"):
			get_tree().change_scene("res://Assets/Levels/level_"+str(GlobalHandler.level)+".tscn")
		else:
			GlobalHandler.level = 0
			get_tree().change_scene("res://Menu.tscn")
			
	player.get_node("HUD/remaining2").value = remaining
	
	#debug_add()
	

	if made >= spawn_limit or remaining <= 0 or max_enemies <= 0:
		return
	
	spawn_timer += delta
	
	if spawn_timer >= spawn_rate:
		var random = rng.randi_range(0,100)
		made+=1
		max_enemies -= 1
		if random <= boss_chance or (remaining == 1 and force_one_boss):
			add_boss()
		else:
			add_one()

func defeat_boss():
	bosses -= 1
	player.refill()
	
func add_boss():
	spawn_timer = 0
	var enemy = enemy_0.instance()
	enemy.father = self
	enemy.buff_up(weapons[rng.randi_range(0,len(weapons)-1)])
	add_child(enemy)
	var random = rng.randi_range(0,get_node("points").get_child_count()-1)
	enemy.global_position = get_node("points").get_child(random).global_position

func add_one():
	
	spawn_timer = 0
	var enemy = enemy_0.instance()
	enemy.father = self
	add_child(enemy)
	var random = rng.randi_range(0,get_node("points").get_child_count()-1)
	enemy.global_position = get_node("points").get_child(random).global_position
	if dummy_generator:
		enemy.make_dummy()

func remove_one():

	made-=1
	remaining -= 1
	spawn_timer = 0
	if weapon_upgrade_level and remaining <= 0:
		player.weapon_upgrade()
	pass
