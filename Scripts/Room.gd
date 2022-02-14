extends Node2D

onready var door_container = get_node("Doors")
onready var playdetector = get_node("PlayerDetector")
onready var shooter_pos_container = get_node("Enemy_Shooter_Spawn")
onready var runner_pos_container = get_node("Enemy_Runner_Spawn")
onready var bullet_manager = get_parent().get_node("BulletManager")
onready var runner = preload("res://scenes/entities/Runner.tscn")
onready var shooter = preload("res://scenes/entities/Shooter.tscn")



var enemy_count = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_PlayerDetector_body_entered(body):
	if body.get_name() == "Player":
		for x in door_container.get_children():
			x.close()
			
		for x in runner_pos_container.get_children():
			var ene = runner.instance()
			ene.connect("tree_exited", self, "_on_enemy_killed")
			ene.position = x.position
			enemy_count += 1
			call_deferred("add_child",ene)
			
		for x in shooter_pos_container.get_children():
			var ene = shooter.instance()
			ene.connect("shooter_fired_bullet", bullet_manager, "handle_bullet_spawned")
			ene.connect("tree_exited", self, "_on_enemy_killed")
			ene.position = x.position
			enemy_count += 1
			call_deferred("add_child",ene)
			
			#todo: spawn animation
			
		playdetector.queue_free()
		
func _on_enemy_killed():
	enemy_count -= 1
	
	#Open door if all are killed
	if enemy_count == 0:
		for x in door_container.get_children():
			x.open()
