extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$AudioStreamPlayer2D.stream = preload("res://Audio/Teleport Sound Effect HD _ No Copyright [frr1D9gas4k].wav")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _turn_on():
	$Sprite.frame = 1
	$AnimationPlayer.play("Teleport")
	$AudioStreamPlayer2D.play()
