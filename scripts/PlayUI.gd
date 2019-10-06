extends Control

var currScore = 0
var currTime = 90

func set_score(newScore):
	currScore = newScore
	update_score_label()

func set_time(newTime):
	currTime = newTime
	update_time_label()

func increment_score():
	currScore += 1
	update_score_label()

func decrement_score():
	currScore -= 1
	update_score_label()

func update_score_label():
	$TexturePanel/MarginContainer/GridContainer/ScoreValueLabel.text = str(currScore)

func update_time_label():
	$TexturePanel/MarginContainer/GridContainer/TimeValueLabel.text = str(currTime)









