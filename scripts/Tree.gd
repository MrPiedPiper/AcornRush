extends Node2D

var moveAmount = 64
onready var tween = $Tween
var playerTweenDuration = .125 #Seconds
var bufferedMovement = null
var isMovingPlayer = false
var isPreIdleTimerDone = true

var playerGridPos = Vector2()

var projectileScene = preload("res://scenes/Projectile.tscn")

var storedFood = []

func _init():
	
	pass

func _process(delta):
	if  !isMovingPlayer and bufferedMovement != null:
		move_player(bufferedMovement)
		bufferedMovement = null	
	if isPreIdleTimerDone:
		$Player/AnimationPlayer.play("Idle")
		$Player/Sprite.flip_h = false
		$Player/Sprite.flip_v = false

func _on_Player_move_player(moveDir):
	#If it can move, do. Otherwise, set the buffer and return.
	if isMovingPlayer:
		#TODO: Don't move diagonally
		bufferedMovement = moveDir
		return
	move_player(moveDir)

func move_player(moveDir):
	$PreIdleTimer.start()
	isPreIdleTimerDone = false
	if moveDir.x != 0:
		$Player/Sprite.flip_v = false
		$Player/AnimationPlayer.play("Run")
		if moveDir.x < 0:
			$Player/Sprite.flip_h = true
		else:
			$Player/Sprite.flip_h = false
	elif moveDir.y != 0:
		$Player/AnimationPlayer.play("Climb")
		if(moveDir.y < 0):
			$Player/Sprite.flip_v = false
		else:
			$Player/Sprite.flip_v = true
	#TODO Replace with an actual check
	if check_movement($Player.position + moveDir * moveAmount):
		return
	isMovingPlayer = true
	tween.interpolate_property(
		$Player, 
		'position', 
		$Player.position, 
		$Player.position + moveDir * moveAmount, 
		playerTweenDuration, 
		Tween.TRANS_QUAD, 
		Tween.EASE_OUT,
		0)
	tween.start()

func _on_Tween_tween_completed(object, key):
	if object == $Player:
		playerGridPos = $Player.position
		isMovingPlayer = false

func check_movement(newPos):
	var tileCoords = $FunctionalTiles.world_to_map(newPos/2)
	var tile = $FunctionalTiles.get_cellv(tileCoords)
	if tile == 0: #Climbable
		return false
	if tile == 1: #Walkable
		return false
	#Do I even *need* 2 kinds of these? I guess if I wanted a walkable area that goes up and down too I would.
	return true

func _on_PreIdleTimer_timeout():
	isPreIdleTimerDone = true

func _on_Player_shoot_projectile():
	var tileCoords = $FunctionalTiles.world_to_map($Player.position/2)
	var tile = $FunctionalTiles.get_cellv(tileCoords)
	if tile == 1:
		#TODO: shoot
		$Player.heldFood.remove($Player.heldFood.size()-1)
		print(str("Shot a thing, remaining items: ",$Player.heldFood.size()))
		#proj.moveDir
		var newProjectile = projectileScene.instance()
		newProjectile.setMoveDir(Vector2($Player.facing,0))
		newProjectile.position = playerGridPos
		newProjectile.connect("move_projectile", self, "_on_Projectile_move_projectile")
		$Projectiles.add_child(newProjectile)

func _on_Projectile_move_projectile(object, dir):
	var newPos = object.position + dir * moveAmount
	var tileCoords = $FunctionalTiles.world_to_map(newPos/2)
	var tile = $FunctionalTiles.get_cellv(tileCoords)
	
	if tile == 1 or tile == 0:
		object.moveTo(newPos)
	else:
		object.queue_free()




















