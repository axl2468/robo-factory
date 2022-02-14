extends StaticBody2D

onready var anim = get_node("AnimationPlayer")

onready var door_sound = get_node("DoorSound")
onready var sound_effect = preload("res://Audio/mixkit-futuristic-door-open-183.mp3")



# Called when the node enters the scene tree for the first time.
func _ready():
	door_sound.stream = sound_effect
	
func open():
	anim.play("open")
	door_sound.play()

func close():
	anim.play("close")
	door_sound.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
