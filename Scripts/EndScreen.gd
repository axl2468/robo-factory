extends Node2D


var end_coin
var end_time
var end_score

var end_min = 0
var end_sec = 0

onready var tween = get_node("Tween")
onready var ding = preload("res://Audio/mixkit-space-coin-win-notification-271.wav")


# Called when the node enters the scene tree for the first time.
func _ready():
	$Doot.stream = ding
	
func _startCount(coins, time, score):
	end_coin = coins
	end_score = score
	
	end_sec = time % 60
	end_min = (time - end_sec)/60
	
	tween.interpolate_method(self, "_increaseCoin", 0, end_coin, 0.5)
	tween.start()
	yield(tween,"tween_all_completed")
	
	tween.interpolate_method(self, "_increaseSecond", 0, end_sec, 1.0)
	tween.start()
	yield(tween,"tween_all_completed")
	
	tween.interpolate_method(self, "_increaseMinute", 0, end_min, 1.0)
	tween.start()
	yield(tween,"tween_all_completed")
	
	tween.interpolate_method(self, "_increaseScore", 0, end_score, 1.0)
	tween.start()
	yield(tween,"tween_all_completed")
	
	$End/name.show()
	$End/Main.show()
	$End/LineEdit.show()
	
func _increaseCoin(coins):
	coins = int(stepify(coins, 1))
	$End/Coins.text = str(coins)
	
func _increaseSecond(second):
	second = int(stepify(second,1))
	if end_sec == 0:
		$End/Time/Seconds.text = "00"
	elif end_sec < 10 and end_sec > 0:
		$End/Time/Seconds.text = "0"+str(second)
	else:
		$End/Time/Seconds.text = str(second)
	
func _increaseMinute(minut):
	minut = int(stepify(minut,1))
	if end_min == 0:
		$End/Time/Minutes.text = "00"
	elif end_min > 0 and end_min < 10:
		$End/Time/Minutes.text = "0"+str(minut)
	else:
		$End/Time/Minutes.text = str(minut)
func _increaseScore(score):
	score = int(stepify(score,1))
	$End/Score.text = str(score)
	$Doot.play()

func _on_ExitEnd_pressed():
	get_tree().change_scene("res://scenes/rooms/MainMenu.tscn")


func _on_Submit_pressed():
	$End/LineEdit.editable = false
	$End/Main/Submitting.show()
	$End/Main/Submit.hide()
	$End/Main/ExitEnd.hide()
	var player_name = $End/LineEdit.get_text()
	var time_sub = OS.get_time(true)
	var hour = time_sub.get("hour") + 8
	if hour > 24:
		hour -= 24
	var metadata = {
		"hour": hour,
		"minute": time_sub.get("minute"),
		"second": time_sub.get("second")
	}
	SilentWolf.Scores.persist_score(player_name, end_score, "main", metadata)
	
	yield(SilentWolf.Scores.get_high_scores(), "sw_scores_received")
	
	get_tree().change_scene("res://Leaderboard/Scores/Leaderboard.tscn")
