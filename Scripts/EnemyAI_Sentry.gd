extends KinematicBody2D

var hp = 14
var flash = false
var cooldown = false

onready var player = get_tree().current_scene.get_node_or_null("Player")
onready var nav = get_tree().current_scene.get_node("Navigation2D")
onready var bullet_scene = preload("res://scenes/entities/SentryBullet.tscn")

onready var death_sound = preload("res://Audio/mixkit-short-explosion-1694.wav")
onready var laser_sound = preload("res://Audio/enemy_laster.wav")
onready var coin = preload("res://scenes/entities/Coin.tscn")

onready var hitbox = get_node("RunnerHitbox")

var dead = false

#signal
signal shooter_fired_bullet(bullet, position, direction)


# Called when the node enters the scene tree for the first time.
func _ready():
	if player:
		player.connect("player_die", self, "_player_die")
	$AttackSound.stream = laser_sound
	set_physics_process(false)
	$AnimationPlayer.play("Appear")
	yield($AnimationPlayer, "animation_finished")
	$DeathSound.stream = death_sound
	$Sprite.show()
	set_physics_process(true)
	
func _physics_process(_delta):
	_shoot_check()
	#Animation
	
	for x in hitbox.get_overlapping_areas(): #collision check
		if x.get_parent().get_name() == "Player":
			pass
			
	
func handle_hit_enemy():
	hp -= 1
	
	#flash animation
	if flash == false:
		flash = true
		$Sprite.modulate = Color(255.0, 5.0, 5.0)
		yield(get_tree().create_timer(0.05), "timeout")
		$Sprite.modulate = Color(1.0,1.0,1.0)
		flash = false
	else:
		pass
		
	if hp == 0:
		_enemy_die()

func _shoot_check():
	if player:
		var look = get_node("RayCast2D")
		look.cast_to = (player.global_position - get_global_position())
		look.force_raycast_update()
		if !cooldown and !look.is_colliding() and !dead and (player.global_position - get_global_position()).length() < 100:
			cooldown = true
			_enemy_fire()
			yield(get_tree().create_timer(2), "timeout") #fire cooldown
			cooldown = false
		
		
func _enemy_fire():
	if !dead:
		var bullet_instance = bullet_scene.instance()
		$AnimationPlayer.play("Walk")
		yield($AnimationPlayer, "animation_finished")
		$AttackSound.play()
		var direction = (player.global_position - get_global_position()).normalized() #normalize to 1
		emit_signal("shooter_fired_bullet", bullet_instance, get_global_position(), direction)
		$AnimationPlayer.play("Idle")

func _enemy_die():
	dead = true
	set_physics_process(false)
	$CollisionShape2D.queue_free() #removes collision to avoid gameplay interference
	$RunnerHitbox.queue_free()
	$Sprite.hide()
	$DeathSound.play()
	$AnimationPlayer.play("Destroy")
	
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Destroy" and !$DeathSound.is_playing():
		$AnimationPlayer.queue_free()
		_drop_pickup()
		queue_free()
	
	
func _player_die(x,y):
	set_physics_process(false)

func _drop_pickup():
	var coin_ins = coin.instance()
	coin_ins.global_position = get_global_position()
	get_parent().call_deferred("add_child",coin_ins)



