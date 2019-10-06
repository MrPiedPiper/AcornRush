extends Control

var currScore = 0

func set_score(newScore):
	currScore = newScore
	update_score_label()

func increment_score():
	currScore += 1
	update_score_label()

func decrement_score():
	currScore -= 1
	update_score_label()

func update_score_label():
	$TextureRect/MarginContainer/HBoxContainer/ScoreValueLabel.text = str(currScore)









