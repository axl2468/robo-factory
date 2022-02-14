extends KinematicBody2D

var ms = 70
var motion = Vector2()
var hp = 5
var flash = false

onready var player = get_tree().current_scene.get_node_or_null("Player")
onready var nav = get_tree().current_scene.get_node("Navigation2D")

onready var hitbox = get_node("RunnerHitbox")

onready var death_sound = preload("res://Audio/mixkit-short-explosion-1694.wav")
onready var battery = preload("res://scenes/entities/Battery.tscn")

#movement and chase state
var direction = Vector2()
var path
var vector_to_next_point


# Called when the node enters the scene tree for the first time.
func _ready():
	if player:
		player.connect("player_die", self, "_player_die")
	set_physics_process(false)
	$AnimationPlayer.play("Appear")
	yield($AnimationPlayer, "animation_finished")
	$DeathSound.stream = death_sound
	$Sprite.show()
	set_physics_process(true)
	
func _physics_process(_delta):
	_pathfinding()
	#Animation
	if path:
		$AnimationTree.get("parameters/playback").travel("Walk")
	else:
		$AnimationTree.get("parameters/playback").travel("Idle")
	if motion.x < -50:
		$Sprite.flip_h = true
	else:
		$Sprite.flip_h = false
	motion = direction*ms
	move_and_slide(motion)
	
	for x in hitbox.get_overlapping_areas(): #collision check
		if x.get_parent().get_name() == "Player":
			x.get_parent().handle_hit_player(10) #param: damage done
			
	
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

func _pathfinding() -> void:
	if path and !flash:
		vector_to_next_point = path[0] - get_global_position()
		var distance_to_point = vector_to_next_point.length()
		if distance_to_point < 3:
			path.remove(0)
			if !path:
				return
		direction = vector_to_next_point.normalized()
	else:
		direction = Vector2()


func _enemy_die():
	set_physics_process(false)
	$CollisionShape2D.queue_free() #removes collision to avoid gameplay interference
	$RunnerHitbox.queue_free()
	$Sprite.hide()
	$DeathSound.play()
	$AnimationPlayer.play("Destroy")
	yield($AnimationPlayer, "animation_finished")
	queue_free()
	
func _player_die(x,y):
	set_physics_process(false)
	$AnimationTree.get("parameters/playback").travel("Idle")
	$PathFindingTimer.queue_free()


func _on_PathFindingTimer_timeout():
	path = nav.get_simple_path(get_global_position(),player.global_position,false)

func _drop_pickup():
	randomize()
	var output = rand_range(1,10)
	print(output)
	if output >= 5: #around 50% chance. i guess?
		var battery_ins = battery.instance()
		battery_ins.global_position = get_global_position()
		get_parent().call_deferred("add_child",battery_ins)
