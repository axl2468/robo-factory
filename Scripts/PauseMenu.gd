extends Node2D

var paused = false #pause_state

# Called when the node enters the scene tree for the first time.

signal game_paused()
signal game_unpaused()

func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if !paused:
			show()
			get_tree().paused = true
			paused = true
			emit_signal("game_paused")
		else:
			_on_Resume_pressed()

func _on_Resume_pressed():
	hide()
	get_tree().paused = false
	paused = false
	emit_signal("game_unpaused")

func _on_Exit_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://scenes/rooms/MainMenu.tscn")
