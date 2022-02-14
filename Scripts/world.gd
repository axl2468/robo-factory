extends Node

onready var bullet_manager = get_node("Room_Entities/BulletManager")
onready var player = get_node("Player")
onready var camera = get_node("Camera2D")
onready var gfx_container = get_node("GraphicalEffects")

onready var hud = preload("res://scenes/entities/HUD.tscn")
onready var dark_fx = preload("res://scenes/room_entity/DarkEffect.tscn")

onready var music = preload("res://Audio/Monplaisir_-_15_-_Bass.mp3")

var hud_node
var dark_fx_node

var coins_collected = 0
var score
var time_taken = 0

var time_start
var time_end

var hp_end


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	SilentWolf.configure({
			  "api_key": "ottr8lmjco9P3yO4o7F9Z4TkfLh2G4g625cxhnRL",
			  "game_id": "RobotFactory1",
			  "game_version": "1.0.0",
			  "log_level": 1
			})

	SilentWolf.configure_scores({
			  "open_scene_on_close": "res://scenes/rooms/MainMenu.tscn"
			})
	_canvaslayer_setup()
	
	hud_node.get_node("Music").stream = music
	hud_node.get_node("Music").play()
	
	#Player setup in world
	player.set_physics_process(false)
	player.connect("player_fired_bullet", bullet_manager, "handle_bullet_spawned")
	player.connect("tree_exited", self, "_on_player_killed")
	player.connect("player_hit", self, "_hp_hud_change")
	player.connect("heal", self, "_hp_hud_change")
	player.connect("coin_collect", self, "_coin_hud_increase")
	player.connect("player_die", self, "_on_player_killed")
	player.connect("_end_game", self, "_on_game_end")
	player.connect("player_dashed", self, "_on_player_dash")
	
	for x in get_node("Room_Entities/Sentries").get_children():
		x.connect("shooter_fired_bullet", bullet_manager, "handle_bullet_spawned")
	
	yield(get_tree().create_timer(1), "timeout")
	
	_fade_in()
	yield(dark_fx_node.get_node("AnimationPlayer"), "animation_finished")
	
	start_timer()
	player.set_physics_process(true)
	
func _physics_process(delta):
	if Input.is_action_just_pressed("ui_debug"):
		pass

func _canvaslayer_setup():
	var hud_i = hud.instance()
	var dark_i = dark_fx.instance()
	gfx_container.add_child(hud_i) #create hud
	hud_i.add_child(dark_i) #create dark_fx inside hud instances
	
	hud_node = get_node_or_null("GraphicalEffects/HUD") #creates new identifiers to newly created nodes
	dark_fx_node = get_node_or_null("GraphicalEffects/HUD/DarkFX")
	
	hud_node.get_node("Ding").stream = preload("res://Audio/Video Game Beep - Sound Effect [B14L61fYZlc].wav")
	
	hud_node.get_node("Pause").connect("game_paused", self, "stop_timer")
	hud_node.get_node("Pause").connect("game_paused", self, "start_timer")
	
func stop_timer():
	time_end = OS.get_unix_time()
	if time_start and time_end:
		time_taken += time_end - time_start
	
func start_timer():
	time_start = OS.get_unix_time()

func _hp_hud_change(health):
	var hp = hud_node.get_node("Health/ProgressBar")
	hp.value = health
	hp_end = hud_node.get_node("Health/ProgressBar").value

func _coin_hud_increase(count):
	var coin = hud_node.get_node("Label")
	coin.set_text(var2str(count))
	coins_collected = count

func _on_player_killed(playerx, playery):
	time_end = OS.get_unix_time()
	time_taken += time_end - time_start
	camera.current = true
	camera.position.x = playerx
	camera.position.y = playery
	
	score = _calculate_score(1, coins_collected)
	
	for x in get_node("Room_Entities/Sentries").get_children():
		x.queue_free()
	
	yield(get_tree().create_timer(2),"timeout")
	_post_game()
	
func _on_game_end(playerx, playery):
	time_end = OS.get_unix_time()
	time_taken += time_end - time_start
	camera.current = true
	camera.position.x = playerx
	camera.position.y = playery
	
	score = _calculate_score(time_taken, coins_collected)
	
	print(score)
	
	for x in get_node("Room_Entities/Sentries").get_children():
		x.queue_free()
	
	yield(get_tree().create_timer(2),"timeout")
	_post_game()
	
func _calculate_score(time_taken, coins_collected):
	var time_multiplier = clamp((900-time_taken),1,900)
	var coin_multiplier = int(round(coins_collected*2.5))
	var x = (time_multiplier * (coin_multiplier)) + 500 + (randi() % 500) #MAAAAATH
	return x
	
func _fade_in():
	dark_fx_node.get_node("AnimationPlayer").play("fadeIn")
	
func _post_game():
	hud_node.get_node("Music").volume_db = -25
	var end_screen = hud_node.get_node("EndScreen")
	
	dark_fx_node.get_node("AnimationPlayer").play("fadeOut")
	hud_node.get_node("HealthBar").queue_free() #remove everything except for end_screen
	hud_node.get_node("DashCD").queue_free()
	hud_node.get_node("Tween").queue_free()
	hud_node.get_node("Ding").queue_free()
	hud_node.get_node("Health").queue_free()
	hud_node.get_node("DashCooldown").queue_free()
	hud_node.get_node("Label").queue_free()
	hud_node.get_node("Pause").queue_free()
	
	end_screen.show()
	hud_node.get_node("AnimationPlayer").play("showup")
	yield(hud_node.get_node("AnimationPlayer"), "animation_finished")
	
	end_screen._startCount(coins_collected, time_taken, score)
	
	print(score)
	
func _on_player_dash():
	var cd = false
	var dashcd = hud_node.get_node("DashCD")
	var tween = hud_node.get_node("Tween")
	var ding = hud_node.get_node("Ding")
	if !cd:
		tween.interpolate_property(dashcd, "value", 0, 100, 1.4, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
		cd = true
		yield(tween, "tween_all_completed")
		ding.play()
		cd = false


func _temporary_storage():
	#tween.interpolate_property(end_coins, "text", "0", str(coins_collected), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	#tween.start()
	#yield(tween, "tween_all_completed")
	
	#tween.interpolate_property(end_time, "text", "0", str(time_taken), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	#tween.start()
	#yield(tween, "tween_all_completed")
	
	#tween.interpolate_property(end_score, "text", "0", str(score), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	#tween.start()
	#yield(tween, "tween_all_completed")
	pass

	



