extends KinematicBody2D

onready var x = get_node("Label")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	x.set_text(get_global_mouse_position()) 
