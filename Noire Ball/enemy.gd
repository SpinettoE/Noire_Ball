extends RigidBody2D

var player
var father
var gun_ptr = null
var gun_ejector
var rng = RandomNumberGenerator.new()
export var weapon = "Unarmed"
export var health = 100
export var dummy = false
export var boss = false


var gun_x
var weapon_damage = 0
var attack_timer = 0
var weapon_timer = 0
var weapon_timer_cap = 0
var firing = false
var grace_timer = 0
var on_grace = true

var movement = Vector2(0,0)

var jump_timer = 2

func buff_up(weap):
	boss = true
	weapon = weap
	gun_ejector = get_node("weapons/"+weapon+"/ejection")

func make_dummy():
	dummy = true
	$body/enemy.play("dummy")

func be_shot(damage,where,multiplier):
	
	var point = where - position

	
	if player.global_position.x < global_position.x:
		apply_impulse(point,Vector2(point.x,-point.y)*multiplier)
	else:
		apply_impulse(point,Vector2(-point.x,-point.y)*multiplier)
	
	$body/hit.play()
	health -= damage

func weapon_stats_update():
	
	match weapon:
		"Revy":
			weapon_timer_cap = 1
			weapon_damage = 15
		"Thommy":
			weapon_timer_cap = 0.08
			weapon_damage = 15
	pass
	
func _ready():
	add_to_group("enemies")
	$body/health_bar.value = health
	player = get_parent().get_parent().get_node("hero")
	gun_ptr = get_node("weapons/"+weapon)
	gun_x = gun_ptr.position.x
	rng.randomize()
	$body/enemy.play("enemy"+str(rng.randi_range(0,3)))
	

func _process(delta):
	
	$body/health_bar.value = health
	
	
			
	gun_ptr.look_at(player.position)
	
	if health <= 0 or (abs(player.global_position.y - global_position.y)>5000):
		if father:
			father.remove_one()
		if boss:
			father.defeat_boss()
		queue_free()
		

	
	weapon_stats_update()
	
	for i in get_node("weapons").get_children():
		if i.name == weapon:
			i.visible = true
	
	
	
	weapon_timer += delta
	attack_timer += delta
	if attack_timer >= 5 and boss:
		attack_timer = 0
		firing = true
		
		
	if gun_ptr.position.x < gun_x:
		gun_ptr.position.x += 1
	if gun_ptr.position.x < gun_x - 50:
		gun_ptr.position.x = gun_x - 50
		
		
	if firing:
		gun_ejector.eject(weapon)
		gun_ptr.position.x -= 15
		gun_ptr.get_node("flash").scale.x = rng.randf_range(0.3,1.5)
		gun_ptr.get_node("flash").scale.y = rng.randf_range(1,1.5)
		get_node("weapons/"+weapon+"/flash").visible = true
		get_node("weapons/"+weapon+"/sprite").play("shoot")
		var collider = get_node("weapons/"+weapon+"/ray").get_collider()
		get_node("weapons/"+weapon+"/shoot").play()
		
		if collider and collider.is_in_group("enemies"):
			collider.be_shot(weapon_damage,get_node("weapons/"+weapon+"/ray").get_collision_point(),1)
		elif collider == player:
			collider.be_shot(weapon_damage,get_node("weapons/"+weapon+"/ray").get_collision_point())
		
		weapon_timer = 0
		firing = false
	else:
		if weapon != "Unarmed":
			get_node("weapons/"+weapon+"/sprite").play("idle")
			get_node("weapons/"+weapon+"/flash").visible = false
	jump_timer -= delta
	if jump_timer < 0:
		jump_timer = 0
	
func _physics_process(delta):

	grace_timer += delta
	if grace_timer < 3:
		if $body/enemy.visible:
			$body/enemy.visible = false
		else:
			$body/enemy.visible = true
	else:
		$body/enemy.visible = true
		on_grace = false
		if dummy:
			sleeping = true
			
	if dummy:
		return
		
	movement.y = 3
	rotation_degrees = 0;

	if player.global_position.x < global_position.x:
		get_node("body/enemy").scale.x = - 0.3
		gun_ptr.scale = Vector2(gun_ptr.scale.x,-abs(gun_ptr.scale.y))
		apply_central_impulse(Vector2(-5,0))

		
	if player.global_position.x > global_position.x: 
		get_node("body/enemy").scale.x  = 0.3
		gun_ptr.scale = Vector2(gun_ptr.scale.x,abs(gun_ptr.scale.y))
		apply_central_impulse(Vector2(5,0))

		
	if player.global_position.y > global_position.y: 
		apply_central_impulse(Vector2(0,5))
	
	if jump_timer <= 0:
		jump_timer = 15 
		apply_central_impulse(Vector2(0,-15)*20)

		


