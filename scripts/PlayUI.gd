extends Control

var currScore = 0

func set_score(newScore):
	currScore = newScore

func increment_score():
	currScore += 1

func decrement_score():
	currScore -= 1

func update_score_label():
	$MarginContainer/HBoxContainer/ScoreValueLabel.text = currScore









