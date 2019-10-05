extends Node2D

signal move_projectile

export(Texture) var projectileSprite
export(Vector2) var moveDir = Vector2(1,0)

func setMoveDir(newMoveDir):
	print(str(newMoveDir))
	moveDir = newMoveDir
	if moveDir.x < 0:
		$Sprite.flip_v = true
	else:
		$Sprite.flip_v = false

func _ready():
	$Sprite.texture = projectileSprite

func _on_Timer_timeout():
	emit_signal("move_projectile", self, moveDir)
