extends Node

class Food:
	var foodType : String
	var foodValue : int

func newFood(type, value):
	var food = Food.new()
	food.foodType = type
	food.foodValue = value
	return food