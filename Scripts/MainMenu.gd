extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var music = preload("res://Audio/HeatleyBros - HeatleyBros IV - 18 Dark Conspiracy.mp3")
var pressed_enter = false

# Called when the node enters the scene tree for the first time.
func _init():
	pass


func _ready():
	SilentWolf.configure({
			  "api_key": "ottr8lmjco9P3yO4o7F9Z4TkfLh2G4g625cxhnRL",
			  "game_id": "RobotFactory1",
			  "game_version": "1.0.0",
			  "log_level": 1
			})

	SilentWolf.configure_scores({
			  "open_scene_on_close": "res://scenes/rooms/MainMenu.tscn"
			})

	$MainMusic.stream = music
	$MainMusic.play()
	yield(get_tree().create_timer(2),"timeout")
	if $Control:
		$Control/AnimationPlayer.play("titleSlide")
		yield($Control/AnimationPlayer, "animation_finished")
		$Control/AnimationPlayer.play("blink")
	
func _unhandled_input(event):
	if Input.is_action_pressed("start_enter") and !pressed_enter:
		pressed_enter = true
		$Control.queue_free()
		$Main.show()

func _on_Play_pressed() -> void:
	get_tree().change_scene("res://scenes/rooms/Level.tscn")


func _on_Tutorial_pressed() -> void:
	get_tree().change_scene("res://scenes/rooms/Tutorial.tscn")


func _on_Credits_pressed():
	$Main.hide()
	$Credits.show()


func _on_CreditsBack_pressed():
	$Credits.hide()
	$Main.show()


func _on_Leaderboards_pressed():
	get_tree().change_scene("res://Leaderboard/Scores/Leaderboard.tscn")
	$MainMusic.stop()
