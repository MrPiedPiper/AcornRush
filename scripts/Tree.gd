extends Node2D

signal food_changed
signal time_changed

var maxTime = 90
var currTime = 90

var difficulty = 10 #Inverse difficulty. 1 is hard, 10 is easy.

var moveAmount = 64
onready var tween = $Tween
var playerTweenDuration = .125 #Seconds
var bufferedMovement = null
var isMovingPlayer = false
var isPreIdleTimerDone = true

var playerGridPos = Vector2()

var projectileScene = preload("res://scenes/Projectile.tscn")

var foodProvider = preload("res://scripts/customClasses/FoodProvider.gd").new()
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
		var newProjectile = projectileScene.instance()
		newProjectile.setMoveDir(Vector2($Player.facing,0))
		newProjectile.position = playerGridPos
		newProjectile.foodVar = $Player.heldFood[$Player.heldFood.size()-1]
		$Player.heldFood.remove($Player.heldFood.size()-1)
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

func _on_TreeHole_hit_food(owner):
	if owner.is_in_group("Food"):
		var newFood = foodProvider.newFood(owner.foodVar.foodType,owner.foodVar.foodValue)
		storedFood.append(newFood)
		emit_signal("food_changed", get_food_value())
		print(str(get_food_value()))
		owner.queue_free()

func get_food_value():
	var total = 0
	for i in range(0, storedFood.size()):
		total += storedFood[i].foodValue
	return total

func _on_CountdownTimer_timeout():
	if currTime > 0:
		currTime -= 1
		emit_signal("time_changed", currTime)
		$CountdownTimer.start()

func _on_ThiefSpawnTimer_timeout():
	#Summon baddie
	print("Fake baddie")
	#Update time
	if get_food_value() == 0:
		$ThiefSpawnTimer.start()
	else:
		var newTime = float(10) / (1+float(get_food_value())/1500)
		if newTime > 4:
			$ThiefSpawnTimer.wait_time = newTime
		$ThiefSpawnTimer.start()

func spawn_thief():
	#TODO:
	#Pick a random spot (1-6)
	#Navigate to that tile
	#Pickup food when passing over the TreeHole
	#Update score
	#Head for the edge of the screen
	#Drop food to the ground when shot
	#Zip off screen
	pass






















