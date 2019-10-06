extends Node2D

func _on_Tree_food_changed(newScore):
	$UI/PlayUI.set_score(newScore)
