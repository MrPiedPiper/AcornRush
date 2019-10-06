extends Node2D

signal move_projectile

export(Texture) var projectileSprite
export(Vector2) var moveDir = Vector2(1,0)

onready var tween = $Tween
var tweenDuration = 0.5
var moveAmount = 64

var foodVar

func setFood(newFood):
	foodVar = newFood
	var newTexture = load(newFood.foodTexturePath)
	$Sprite.texture = newTexture
	projectileSprite = newTexture
	print(str("Setting texture to: ",newFood.foodTexturePath))

func setMoveDir(newMoveDir):
	print(str(newMoveDir))
	moveDir = newMoveDir
	if moveDir.x < 0:
		$Sprite.flip_v = true
	else:
		$Sprite.flip_v = false

func _ready():
	$Sprite.texture = projectileSprite
	emit_signal("move_projectile", self, moveDir)
	$Timer.start()

func _on_Timer_timeout():
	emit_signal("move_projectile", self, moveDir)


func _on_Tween_tween_completed(object, key):
	pass#emit_signal("move_projectile", self, moveDir)

func moveTo(newPos):
	tween.interpolate_property(
		self, 
		'position', 
		position, 
		newPos,
		tweenDuration, 
		Tween.TRANS_QUAD, 
		Tween.EASE_OUT,
		0)
	tween.start()
