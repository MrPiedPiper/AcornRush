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

var thiefScene = preload("res://scenes/Thief.tscn")
var foodPickupScene = preload("res://scenes/FoodPickup.tscn")
var goldenAcornTexture = preload("res://images/golden_acorn_spawner.png") #TODO Replace with actual image

var isPlayerFalling = false
var isPlayerNavigating = false
var targetCoords = Vector2()

func _ready():
	playerGridPos = $Player.position

func _process(delta):
	if  !isMovingPlayer and !isPlayerNavigating and bufferedMovement != null:
		move_player(bufferedMovement)
		bufferedMovement = null	
	if isPreIdleTimerDone:
		$Player/AnimationPlayer.play("Idle")
		$Player/Sprite.flip_h = false
		$Player/Sprite.flip_v = false

func _on_Player_move_player(moveDir):
	#If it can move, do. Otherwise, set the buffer and return.
	if isMovingPlayer or isPlayerNavigating:
		#TODO: Don't move diagonally
		bufferedMovement = moveDir
		return
	move_player(moveDir)

func move_player(moveDir):
	play_walk()
	tween.stop_all()
	$PreIdleTimer.start()
	isPreIdleTimerDone = false
	if moveDir.x != 0:
		$Player/AnimationPlayer.play("Run")
		$Player/Sprite.flip_v = false
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
	if !isPlayerNavigating and check_movement($Player.position + moveDir * moveAmount):
		return
	isMovingPlayer = true
	tween.interpolate_property(
		$Player, 
		'position', 
		$Player.position, 
		playerGridPos + moveDir * moveAmount, 
		playerTweenDuration, 
		Tween.TRANS_QUAD, 
		Tween.EASE_OUT,
		0)
	tween.start()

func _on_Tween_tween_completed(object, key):
	playerGridPos = $Player.position
	isMovingPlayer = false
	if isPlayerNavigating:
		if playerGridPos == targetCoords:
			isPlayerNavigating = false
		else:
			$FallTimer.start()

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
	var playerTouchingList = $Player.touchingList
	for i in range(0,playerTouchingList.size()):
		var currOwner = playerTouchingList[i-1].owner
		if currOwner.is_in_group("TreeHole"):
			for l in range(0,$Player.heldFood.size()):
				var newFood = $Player.heldFood[l-1]
				storedFood.append(newFood)
			$Player.heldFood.clear()
			emit_signal("food_changed", get_food_value())
			$CArpeggioSound.play(0)
			return
	var tileCoords = $FunctionalTiles.world_to_map($Player.position/2)
	var tile = $FunctionalTiles.get_cellv(tileCoords)
	if tile == 1:
		$ShootSound.play(0)
		var newProjectile = projectileScene.instance()
		newProjectile.setMoveDir(Vector2($Player.facing,0))
		newProjectile.position = playerGridPos
		newProjectile.setFood($Player.heldFood[$Player.heldFood.size()-1])
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

func _on_TreeHole_hit_food(theOwner):
	$CArpeggioSound.play(0)
	if theOwner.is_in_group("Food"):
		var newFood = foodProvider.newFood(theOwner.foodVar.foodType,theOwner.foodVar.foodValue,theOwner.foodVar.foodTexturePath)
		storedFood.append(newFood)
		emit_signal("food_changed", get_food_value())
		theOwner.queue_free()

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
	spawn_thief()
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
	var branchNum = randi() % 6 + 1 # returns random integer between 1 and 100
	var newThief = thiefScene.instance()
	newThief.connect("thief_steal_food", self, "_on_Thief_thief_steal_food")
	newThief.connect("thief_drop_food", self, "_on_Thief_dropped_food")
	newThief.position = Vector2(480, -32) #Top left of the trunk, behind the leaves.
	$Thieves.add_child(newThief)
	if branchNum == 1:
		newThief.navigate_to(Vector2(480,96))
	elif branchNum == 2:
		newThief.navigate_to(Vector2(544,96))
	elif branchNum == 3:
		newThief.navigate_to(Vector2(480,224))
	elif branchNum == 4:
		newThief.navigate_to(Vector2(544,224))
	elif branchNum == 5:
		newThief.navigate_to(Vector2(480,352))
	elif branchNum == 6:
		newThief.navigate_to(Vector2(544,352))
	#Pickup food when passing over the TreeHole
	
	#Update score
	#Drop food to the ground when shot
	#Zip off screen
	pass

func _on_Thief_thief_steal_food(thief):
	if storedFood.size() > 0:
		thief.heldFood.append(storedFood[storedFood.size()-1])
		storedFood.remove(storedFood.size()-1)
		if storedFood.size() > 0:
			thief.heldFood.append(storedFood[storedFood.size()-1])
			storedFood.remove(storedFood.size()-1)
		emit_signal("food_changed", get_food_value())

func _on_Thief_dropped_food(thief):
	var newFoodPickup = foodPickupScene.instance()
	var newFood = foodProvider.newFood("Golden Acorn", 200, "res://images/golden_acorn_spawner.png")
	newFoodPickup.change_texture(goldenAcornTexture)
	newFoodPickup.change_food(newFood)
	newFoodPickup.position = thief.position
	newFoodPickup.self_destruct(7)
	for i in range(0,thief.heldFood.size()):
		storedFood.append(thief.heldFood[i])
		emit_signal("food_changed", get_food_value())
	$DroppedFood.add_child(newFoodPickup) 

func _on_Player_fall():
	tween.stop_all()
	#isPlayerFalling = true
	$FallTimer.wait_time = 0.1
	navigate_to(Vector2(playerGridPos.x, 544))

func navigate_to(newCoords):
	isPlayerNavigating = true
	targetCoords = newCoords
	$FallTimer.start()

func _on_FallTimer_timeout():
	move_player(get_direction_from_coords(targetCoords))

func get_direction_from_coords(coords):
	var newDir = (coords - position)
	if newDir.x > newDir.y:
		newDir.y = 0
	else:
		newDir.x = 0
	return newDir.normalized()

func play_walk():
	$WalkSound.play(0)












