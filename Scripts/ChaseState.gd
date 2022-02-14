extends Node2D


onready var enemy = self.get_parent()
onready var player = get_tree().current_scene.get_node_or_null("Player")
var direction


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
