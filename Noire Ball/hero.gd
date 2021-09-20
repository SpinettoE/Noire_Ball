extends KinematicBody2D

var rng = RandomNumberGenerator.new()

var falling = true
var movement = Vector2(0,0)

export var weapon = "Revy"

var weapons = ["Revy","Broomhandle","Thommy","Trenchgun","Levergun"]
var w_cap = 0
var max_ammo = [-1,12,50,5,7]
var ammo = [-1,12,50,5,7]
var impulses = [1,0.2,0.4,1.2,1]
var w_index = 0
var firing = false
var gun_x
var gun_ejector
var gun_pointer
var weapon_damage
var weapon_timer = 0
var weapon_timer_cap = 0
var flash_timer = 0
var anim_finished = true

var jump_ready = true
var jumping = false
var jump_timer = 0

var health = 3
var heart_timer = 0
var hurt_timer = 0

var mirror_h_anchor = Vector2(0,0)
var dash_timer = 3

func weapon_upgrade():
	GlobalHandler.w_cap+=1
	$HUD/weapon_up.visible=true 
	
func refill():
	$HUD/ammo_up.visible = true
	for x in range(len(ammo)):
		ammo[x] += max_ammo[x] /10
		if ammo[x] > max_ammo[x]:
			ammo[x] = max_ammo[x]
		if ammo[x] <= 0:
			ammo[x] += 2

func hurt_service(delta):
	if hurt_timer < 3:
		if $body/hero.visible:
			$body/hero.visible = false
		else:
			$body/hero.visible = true
	else:
		$body/hero.visible = true
	hurt_timer+=delta
	
func health_service(delta):
	heart_timer+= delta
	
	if health <= 0:
		get_tree().change_scene("res://shell_case.tscn")
		
	if dash_timer < 3:
		dash_timer+=delta
	if dash_timer > 3:
		dash_timer = 3
	
	$HUD/dash_level.value = dash_timer
	
	if heart_timer >= 10:
		if health < 3:
			health+=1
			heart_timer = 0
			
	$HUD/heart_1.visible = false
	$HUD/heart_2.visible = false
	$HUD/heart_3.visible = false
	
	match health:
		3:
			$HUD/heart_1.visible = true
			$HUD/heart_2.visible = true
			$HUD/heart_3.visible = true
		2:
			$HUD/heart_1.visible = true
			$HUD/heart_2.visible = true
		1:
			$HUD/heart_1.visible = true
		0:
			pass
	pass

func be_shot(damage,where):
	if hurt_timer >= 3:
		health -= 1
		hurt_timer = 0
		heart_timer = 0
	
func _ready():
	rng.randomize()
	gun_ejector = get_node("weapons/"+weapon+"/ejection")
	gun_pointer = get_node("weapons/"+weapon)
	gun_x = gun_pointer.position.x
	w_cap = GlobalHandler.w_cap
	$body/mirror_hero.modulate.a = 0
	pass # Replace with function body.

func _process(delta):
	

	hurt_service(delta)
	health_service(delta)
	
	gun_ejector = get_node("weapons/"+weapon+"/ejection")
	gun_pointer = get_node("weapons/"+weapon)
	
	if gun_pointer.position.x < gun_x:
		gun_pointer.position.x += 1
	if gun_pointer.position.x < gun_x - 50:
		gun_pointer.position.x = gun_x - 50
		
	if get_node("weapons/"+weapon+"/flash").visible:
		flash_timer += delta
		if flash_timer >= 0.15:
			get_node("weapons/"+weapon+"/flash").visible = false
			flash_timer = 0
		
	gun_pointer.look_at(get_global_mouse_position())
	$weapons/crosshair.position = get_local_mouse_position()
	
	weapon_timer += delta


	if Input.is_action_just_pressed("shoot"):
		firing = true
	if Input.is_action_just_released("shoot"):
		firing = false
	
	if Input.is_action_just_pressed("gun_plus"):
		print("UP")
		w_index += 1
		if w_index>w_cap:
			w_index-=1
	
	if Input.is_action_just_pressed("gun_less"):
		print("DOWN")
		w_index -= 1
		if w_index<0:
			w_index+=1
	
	weapon = weapons[w_index]
	
	for i in get_node("weapons").get_children():
		if i.name != "crosshair":
			i.visible = false
		if i.name == weapon:
			i.visible = true
	
	
	if weapon_timer >= weapon_timer_cap and firing and (ammo[w_index] > 0 or w_index == 0):
		ammo[w_index] -= 1
		gun_ejector.eject(weapon)
		gun_pointer.position.x -= 15
		gun_pointer.get_node("flash").scale.x = rng.randf_range(0.3,1.5)
		gun_pointer.get_node("flash").scale.y = rng.randf_range(1,1.5)
		
		get_node("weapons/"+weapon+"/flash").visible = true
		
		if anim_finished:
			get_node("weapons/"+weapon+"/sprite").play("shoot")
			anim_finished = false
			get_node("weapons/"+weapon+"/shoot").play()

		
		for x in get_node("weapons/"+weapon+"/rays").get_children():
			var collider = x.get_collider()
			if collider!= null and "health" in collider:
				if collider!=null:
					collider.be_shot(weapon_damage,x.get_collision_point(),impulses[w_index])
			
		
		
		weapon_timer = 0
	
	if anim_finished:
		get_node("weapons/"+weapon+"/sprite").play("idle")

	weapon_stats_update()
	
func finish_anim():
	anim_finished = true
	
func weapon_stats_update():
	
	match weapon:
		"Revy":
			weapon_timer_cap = 1
			weapon_damage = 25
			$HUD/ammo_level.value = 100
		"Thommy":
			weapon_timer_cap = 0.08
			weapon_damage = 25
			$HUD/ammo_level.max_value = 50
			$HUD/ammo_level.value = ammo[w_index]
		"Broomhandle":
			weapon_timer_cap = 0.1
			weapon_damage = 20
			$HUD/ammo_level.max_value = 12
			$HUD/ammo_level.value = ammo[w_index]
		"Trenchgun":
			weapon_timer_cap = 1
			weapon_damage = 20
			$HUD/ammo_level.max_value = max_ammo[w_index]
			$HUD/ammo_level.value =  ammo[w_index]
		"Levergun":
			weapon_timer_cap = 0.9
			weapon_damage = 50
			$HUD/ammo_level.max_value = max_ammo[w_index]
			$HUD/ammo_level.value =  ammo[w_index]
		
			
			
	pass

func _physics_process(delta):
	
	if $body/mirror_hero.modulate.a > 0:
		$body/mirror_hero.modulate.a -= 0.05
		$body/mirror_hero.global_position = mirror_h_anchor
	else:
		mirror_h_anchor = $body/hero.global_position
		$body/mirror_hero.scale = $body/hero.scale
		$body/mirror_hero.global_position = $body/hero.global_position
		
	if falling:
		movement = Vector2(movement.x,+5)
	
	movement.x = 0
	
	if Input.is_action_just_pressed("dash") and dash_timer >= 3:
		dash_timer = 0
		mirror_h_anchor = global_position
		$body/mirror_hero.modulate.a = 1
		
		if $body/hero/dash_cast.get_collider():
			global_position = $body/hero/dash_cast.get_collision_point()
		else:
			if $body/hero.scale.x < 0:
				position.x -= 300
			else:
				position.x += 300
			
		
			
	if Input.is_action_pressed("ui_right"):
		get_node("body/hero").scale.x = 1
		gun_pointer.scale = Vector2(abs(gun_pointer.scale.x),abs(gun_pointer.scale.y))
		movement.x = 5
		
	if Input.is_action_pressed("ui_left"):
		get_node("body/hero").scale.x = -1
		gun_pointer.scale = Vector2(abs(gun_pointer.scale.x),-abs(gun_pointer.scale.y))
		movement.x = -5
		
	if Input.is_action_just_pressed("jump"):
		if jump_ready:
			jumping = true
	
	if jumping:
		jump_timer += delta
		if jump_timer < 0.5:
			movement.y = -10
		else:
			jump_timer = 0
			jumping = false
			
	position.x += movement.x
	position.y += movement.y
	
	
		
	move_and_collide(movement)
	
func _on_coll_area_body_entered(body):

	if body.is_in_group("platforms"):
		jump_ready = true
	elif body.is_in_group("enemies"):
		if !body.on_grace:
			be_shot(1,null)

func _on_coll_area_body_exited(body):
	if body.is_in_group("platforms"):
		jump_ready = false
