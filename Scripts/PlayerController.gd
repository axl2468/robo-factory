extends KinematicBody2D

onready var bullet_origin = get_node("BulletRotate/BulletOrigin")
onready var bullet_scene = preload("res://scenes/entities/Bullet.tscn")

onready var laser_sound = preload("res://Audio/mixkit-short-laser-gun-shot-1670.wav")
onready var coin_sound = preload("res://Audio/mixkit-space-coin-win-notification-271.wav")
onready var death_sound = preload("res://Audio/mixkit-short-explosion-1694.wav")
onready var hit_sound = preload("res://Audio/Undertale Sound Effect - Taking Damage.wav")
onready var battery_sound = preload("res://Audio/mixkit-wrong-electricity-buzz-955.wav")
onready var dash_sound = preload("res://Audio/Sonic 3 - Spin Dash Sound Effect [nKYaZAyldt4].wav")

signal player_fired_bullet(bullet, position, direction)
signal player_hit(hp)
signal player_die(playerx,playery)
signal coin_collect(count)
signal heal(health)
signal player_dashed()

signal _end_game()

export var ms = 100
export var fire_rate = 0.25

var motion
var last_vector
var last_motion

var dash_object = preload("res://scenes/entities/DashObject.tscn")
var dashing = false
var dash_cooldown = false

var dead = false
var can_fire = true
var hit_inv = false

#stats
export var health = 100
var coins = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$AttackSound.stream = laser_sound
	$DeathSound.stream = hit_sound
	$DashSound.stream = dash_sound
	$BatterySound.stream = battery_sound
	$CoinSound.stream = coin_sound
	
func _physics_process(_delta):
	var direction = (get_global_mouse_position() - bullet_origin.global_position).normalized()
	
	#movement
	motion = Vector2()
	if !dashing:
		if Input.is_action_pressed("movement_up"):
			motion += Vector2(0,-1)
		if Input.is_action_pressed("movement_down"):
			motion += Vector2(0,1)
		if Input.is_action_pressed("movement_left"):
			motion += Vector2(-1,0)
		if Input.is_action_pressed("movement_right"):
			motion += Vector2(1,0)
		motion = motion.normalized()
	elif dashing:
		_dash()
	$BulletRotate.look_at(get_global_mouse_position())
	
	
	if Input.is_action_pressed("ingame_lmb"):
		fire()
	
	if Input.is_action_just_pressed("movement_dash") and !dash_cooldown:
		last_motion = last_vector
		dashing = true
		$DashTimer.start()
		dash_cooldown = true
		$DashCooldown.start()
		hit_inv = true
		$InvincibilityFrame.start()
		$DashSound.play()
	
	#Animation and Vector Related Stuff
	if motion == Vector2():
		$AnimationTree.get("parameters/playback").travel("Idle")
		if Input.is_action_pressed("ingame_lmb"):
			$AnimationTree.set("parameters/Idle/blend_position", direction)
	else:
		last_vector = motion
		
		$AnimationTree.get("parameters/playback").travel("Walk")
		if Input.is_action_pressed("ingame_lmb"):
			$AnimationTree.set("parameters/Idle/blend_position", motion)
			$AnimationTree.set("parameters/Walk/blend_position", direction)
		else:
			$AnimationTree.set("parameters/Idle/blend_position", motion)
			$AnimationTree.set("parameters/Walk/blend_position", motion)
	move_and_slide(motion*ms)

func _dash():
	emit_signal("player_dashed")
	set_collision_mask(3)
	if last_motion:
		motion = last_motion*5
	else:
		motion = Vector2(1,1)*5
	var dash_node = dash_object.instance()
	dash_node.frame = $Head.frame
	dash_node.global_position = get_global_position()
	get_parent().add_child(dash_node)
	yield(get_tree().create_timer(1),"timeout")
	set_collision_mask(11)
	
func _on_DashTimer_timeout():
	dashing = false
	
func _on_DashCooldown_timeout():
	dash_cooldown = false

func _on_InvincibilityFrame_timeout(): #for a total of 5 frames
	hit_inv = false
		
func fire(): #pew, pew!
	var direction = (get_global_mouse_position() - bullet_origin.global_position).normalized() #normalize to 1
	if can_fire:
		var bullet_instance = bullet_scene.instance()
		
		emit_signal("player_fired_bullet", bullet_instance, bullet_origin.global_position, direction)
		
		$AttackSound.play()
			
		can_fire = false
		yield(get_tree().create_timer(fire_rate), "timeout") #timer
		can_fire = true

func handle_hit_player(damage): #ouch!
	if hit_inv == false and !dead:
		$DeathSound.play()
		health -= damage
		print(health)
		flashing_inv()
		emit_signal("player_hit", health)
	if dead == false and health <= 0:
		dead = true
		die_lose()
		
func die_lose(): #you lost.
	set_physics_process(false)
	$DeathSound.stream = death_sound
	$Head.hide()
	$Destroy.show()
	emit_signal("player_die", self.global_position.x, self.global_position.y)
	$DeathSound.play()
	$AnimationPlayer.play("Die")
	yield($AnimationPlayer, "animation_finished")
	queue_free()

func flashing_inv():
	hit_inv = true
	for x in 6:
		$Head.modulate.a = 0.5
		yield(get_tree().create_timer(0.075), "timeout")
		$Head.modulate.a = 1.0
		yield(get_tree().create_timer(0.075), "timeout")
	hit_inv = false
	
func handle_coin():
	coins += 1
	$CoinSound.play()
	emit_signal("coin_collect", coins)

func handle_battery():
	var add = health + 20
	health = clamp(add, 0, 100)
	$BatterySound.play()
	emit_signal("heal", health)
	
func endu_gamu(area):
	set_physics_process(false)
	global_position = area.get_global_position()
	$AnimationTree.queue_free()
	$Head.frame = 2
	yield(get_tree().create_timer(0.5), "timeout")
	#$AnimationTree.set("parameters/Idle/blend_position", motion)
	area._turn_on()
	$AnimationPlayer.play("Teleport")
	#[insert sound]
	emit_signal("_end_game", self.global_position.x, self.global_position.y)
	yield(area.get_node("AnimationPlayer"), "animation_finished")
	queue_free()


func _on_PlayerCenter_area_entered(area):
	if area.has_method("_turn_on"):
		endu_gamu(area)
