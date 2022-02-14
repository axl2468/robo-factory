extends Node

onready var bullet_manager = get_node("BulletManager")
onready var player = get_node("Player")
onready var camera = get_node("Camera2D")
onready var hp = get_node("HUD/Health/ProgressBar")
onready var coin = get_node("HUD/Label")

#Tutorial elements
onready var movement_instruction = get_node("Labels/Movement")
onready var movement_point = get_node("Labels/Movement/Movement")

onready var shoot_instruction = get_node("Labels/Shoot")
onready var shoot_point = get_node("Labels/Shoot/Shoot")

onready var dummy_point = get_node("Spawning/Enemy")
onready var dummy = preload("res://scenes/entities/Dummy.tscn")

onready var pickup_instruction = get_node("Labels/Pickup")
onready var pickup_point = get_node("Labels/Pickup/Pickup")

onready var pickup2_instruction = get_node("Labels/Pickup2")
onready var pickup2_point = get_node("Labels/Pickup2/Pickup2")

var coins_collected = 0
const coin_multiplier = 1.5
const max_time_score = 1200
var score
var time_taken



# Called when the node enters the scene tree for the first time.
func _ready():
	player.connect("player_fired_bullet", bullet_manager, "handle_bullet_spawned")
	player.connect("tree_exited", self, "_on_player_killed")
	player.connect("player_hit", self, "_hp_hud_change")
	player.connect("heal", self, "_hp_hud_change")
	player.connect("coin_collect", self, "_coin_hud_increase")
	player.connect("player_die", self, "_on_player_killed")
	
	#Spawn dummy
	_spawn_dummy()
	

func _physics_process(_delta):
	movement_instruction.modulate.a = 1 - abs(((player.global_position.x - movement_point.global_position.x)/100)*2)
	shoot_instruction.modulate.a = 1 - abs(((player.global_position.x - shoot_point.global_position.x)/100)*2)
	pickup_instruction.modulate.a = 1 - abs(((player.global_position.x - pickup_point.global_position.x)/100)*0.75)
	pickup2_instruction.modulate.a = 1 - abs(((player.global_position.x - pickup2_point.global_position.x)/100)*0.75)

func _hp_hud_change(health):
	hp.value = health

func _coin_hud_increase(count):
	coin.set_text(var2str(count))
	coins_collected = count

func _on_player_killed(playerx, playery):
	camera.current = true
	camera.position.x = playerx
	camera.position.y = playery
	
func _calculate_score():
	score = (coin_multiplier*coins_collected) + (max_time_score - time_taken)
	
func _spawn_dummy():
	var ene = dummy.instance()
	ene.connect("tree_exited", self, "_spawn_dummy")
	ene.global_position = dummy_point.global_position
	call_deferred("add_child",ene)
	
	



