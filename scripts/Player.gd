extends Node2D

signal move_player
signal pickup_food
signal shoot_projectile
signal fall

var moveDir = Vector2()
var touchingList = []
var heldFood = []
var facing = 1

var foodProvider = preload("res://scripts/customClasses/FoodProvider.gd").new()

func _init():
	pass

func _process(delta):
	moveDir = Vector2()
	if Input.is_action_just_pressed("control_left"):
		moveDir.x -= 1
	if Input.is_action_just_pressed("control_right"):
		moveDir.x += 1
	if Input.is_action_just_pressed("control_up"):
		moveDir.y -= 1
	if Input.is_action_just_pressed("control_down"):
		moveDir.y += 1
	if moveDir != Vector2.ZERO:
		if moveDir.y != 0 and moveDir.x != 0:
			moveDir.y = 0
		move(moveDir)
	if Input.is_action_just_pressed("control_interact"):
		pickup_food()
	if Input.is_action_just_pressed("control_confirm"):
		if heldFood.size() > 0:
			emit_signal("shoot_projectile")

func move(moveDir):
	if moveDir.x != 0:
		facing = moveDir.x
	emit_signal("move_player",moveDir)

func pickup_food():
	for i in range(0,touchingList.size()):
		var theOwner = touchingList[i].owner
		if theOwner.is_in_group("FoodSpawner") and theOwner.hasFood:
			emit_signal("pickup_food")
			var newFood = foodProvider.newFood(theOwner.foodType, theOwner.foodValue, theOwner.get_texture_path())
			heldFood.append(newFood)
			theOwner.resetFood()
			$PickupSound.play(0)
			return
		elif theOwner.is_in_group("FoodPickup"):
			heldFood.append(foodProvider.newFood(theOwner.foodVar.foodType, theOwner.foodVar.foodValue, theOwner.foodVar.foodTexturePath))
			theOwner.queue_free()
			$PickupSound.play(0)
			return

func _on_InteractArea_area_entered(area):
	touchingList.append(area)
	if area.owner.is_in_group("Thief"):
		emit_signal("fall")

func _on_InteractArea_area_exited(area):
	for i in range(0,touchingList.size()):
		if touchingList[i-1] == area:
			touchingList.remove(i)

func get_direction_from_coords(coords):
	var newDir = (coords - position)
	if newDir.x > newDir.y:
		newDir.y = 0
	else:
		newDir.x = 0
	return newDir.normalized()






