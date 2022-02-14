extends KinematicBody2D

var ms = 70
var motion = Vector2()
var hp = 5
var flash = false

onready var player = get_tree().current_scene.get_node_or_null("Player")
onready var nav = get_tree().current_scene.get_node("Navigation2D")

onready var prox = get_node("RunnerProx")
onready var hitbox = get_node("RunnerHitbox")


# Called when the node enters the scene tree for the first time.
func _ready():
	if player:
		player.connect("player_die", self, "_player_die")
	set_physics_process(false)
	$AnimationPlayer.play("Appear")
	yield($AnimationPlayer, "animation_finished")
	$Sprite.show()
	set_physics_process(true)
	
func _physics_process(_delta):
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


func _enemy_die():
	set_physics_process(false)
	$CollisionShape2D.queue_free() #removes collision to avoid gameplay interference
	$Sprite.hide()
	$AnimationPlayer.play("Destroy")
	yield($AnimationPlayer, "animation_finished")
	yield(get_tree().create_timer(1), "timeout")
	queue_free()
