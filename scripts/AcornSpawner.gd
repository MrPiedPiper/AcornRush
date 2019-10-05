extends Node2D

export var chanceOfGrowth = .5
export var growthState = 0
export var maxGrowth = 3
export var foodValue = 1
var hasFood = false
export(Texture) var sprite

func _ready():
	randomize() #TODO: Move this to the main script
	$Sprite.texture = sprite
	$Timer.start()

func _on_Timer_timeout():
	if randf() < chanceOfGrowth:
		set_growth(growthState+1)
	if growthState < maxGrowth:
		$Timer.start()

func set_growth(newGrowth):
	growthState = newGrowth
	$Sprite.region_rect=Rect2(32*growthState,0,32,32)
	if growthState < maxGrowth:
		hasFood = false
		$Area2D/CollisionShape2D.disabled = true
	else:
		hasFood = true
		$Area2D/CollisionShape2D.disabled = false

func resetFood():
	set_growth(0)
	$Timer.start()










