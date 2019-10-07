extends Node2D

func _ready():
	get_tree().paused = true

func _on_Tree_food_changed(newScore):
	$UI/PlayUI.set_score(newScore)

func _on_Tree_time_changed(newTime):
	$UI/PlayUI.set_time(newTime)

func _on_MainMenu_play_pressed():
	$UI/MainMenu.visible = false
	$UI/PlayUI.visible = true
	get_tree().paused = false
