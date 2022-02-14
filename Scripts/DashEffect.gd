extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	modulate.a = lerp(modulate.a, 0, 0.1)
	if modulate.a < 0.01:
		queue_free()
