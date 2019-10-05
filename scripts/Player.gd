extends Node2D

signal move_player
signal pickup_food

var moveDir = Vector2()
var touchingList = []
var heldFood = []

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
	if Input.is_action_just_pressed("control_confirm"):
		pickup_food()

func move(moveDir):
	emit_signal("move_player",moveDir)

func pickup_food():
	for i in range(0,touchingList.size()):
		if touchingList[i].owner.hasFood:
			emit_signal("pickup_food")
			heldFood.append(touchingList[i].owner.foodType)
			touchingList[i].owner.resetFood()

#Doesn't see it if you're sitting on top when it grows?
func _on_InteractArea_area_entered(area):
	if area.owner.name == "FoodSpawner":
		touchingList.append(area)

func _on_InteractArea_area_exited(area):
	for i in range(0,touchingList.size()):
		if touchingList[i] == area:
			touchingList.remove(i)




















