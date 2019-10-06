extends Node

class Food:
	var foodType : String
	var foodValue : int
	var foodTexturePath : String

func newFood(type, value, texturePath):
	var food = Food.new()
	food.foodType = type
	food.foodValue = value
	food.foodTexturePath = texturePath
	return food