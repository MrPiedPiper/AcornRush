extends Node2D

export var foodType = "Acorn"
export var foodValue = 100
export(Texture) var sprite
var foodVar

var foodSupplier = preload("res://scripts/customClasses/FoodProvider.gd").new()

func _ready():
	$Sprite.texture = sprite
	foodVar = foodSupplier.newFood(foodType, foodValue, sprite.get_path())

func change_texture(newTexture):
	sprite = newTexture
	$Sprite.texture = newTexture

func change_food(newFood):
	foodVar = newFood
	foodType = foodVar.foodType
	foodValue = foodVar.foodValue








