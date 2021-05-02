extends Node2D

signal thief_steal_food
signal thief_drop_food

var moveAmount = 64
var heldFood = []
var targetCoords = Vector2()
var isNavigating = false
var isPreIdleTimerDone = true
var isMovingThief = false
var thiefTweenDuration = .25
onready var tween = $Tween
var thiefGridPos = Vector2()
var isLeaving = false
var isFalling = false

var regularTexture = preload("res://images/thief_frames.png")
var bagTexture = preload("res://images/thief_frames_bag.png")

func _ready():
	randomize()
	thiefGridPos = position

func _process(delta):
	if isPreIdleTimerDone:
		$AnimationPlayer.play("Idle")
		$Sprite.flip_h = false
		$Sprite.flip_v = false

func _on_InteractArea_area_entered(area):
	if area.owner.is_in_group("TreeHole"):
		emit_signal("thief_steal_food", self)
	if area.owner.is_in_group("Food"):
		fall()
		area.owner.queue_free()

func give_bag():
	$Sprite.texture = bagTexture

func get_direction_from_coords(coords):
	var newDir = (coords - position)
	if newDir.x > newDir.y:
		newDir.y = 0
	else:
		newDir.x = 0
	return newDir.normalized()

func navigate_to(newCoords):
	isNavigating = true
	targetCoords = newCoords
	#move(get_direction_from_coords(newCoords))
	$Timer.start()

func fall():
	add_to_group("Ignore")
	isFalling = true
	isLeaving = false
	$Timer.wait_time = 0.1
	navigate_to(Vector2(thiefGridPos.x, 544))
	

func move(moveDir):
	$WalkSound.play(0)
	tween.stop_all()
	$PreIdleTimer.start()
	isPreIdleTimerDone = false
	if moveDir.x != 0:
		$AnimationPlayer.play("Run")
		$Sprite.flip_v = false
		if moveDir.x < 0:
			$Sprite.flip_h = true
		else:
			$Sprite.flip_h = false
	elif moveDir.y != 0:
		$AnimationPlayer.play("Climb")
		if(moveDir.y < 0):
			$Sprite.flip_v = false
		else:
			$Sprite.flip_v = true
#	if check_movement($Player.position + moveDir * moveAmount):
#		return
	isMovingThief = true
	tween.interpolate_property(
		self, 
		'position', 
		position, 
		thiefGridPos + moveDir * moveAmount, 
		thiefTweenDuration, 
		Tween.TRANS_QUAD, 
		Tween.EASE_OUT,
		0)
	tween.start()

func _on_Tween_tween_completed(object, key):
	thiefGridPos = position
	isMovingThief = false
	if thiefGridPos != targetCoords:
		$Timer.start()
	elif isLeaving:
		queue_free()
	elif isFalling:
		isFalling = false
		emit_signal("thief_drop_food", self)
		$Sprite.texture = regularTexture
		isNavigating = false
		go_off_screen()
	else:
		isNavigating = false
		go_off_screen()
		

func go_off_screen():
	isLeaving = true
	$Timer.stop()
	var exitOne = Vector2(position.x + 64*8, position.y)
	var exitTwo = Vector2(position.x - 64*8, position.y)
	var target = Vector2()
	print(exitOne.x - exitTwo.x)
	if exitOne.x - exitTwo.x > 0:
		target = exitOne
	else:
		target = exitTwo
	navigate_to(target)

func _on_Timer_timeout():
	move(get_direction_from_coords(targetCoords))

func _on_PreIdleTimer_timeout():
	isPreIdleTimerDone = true
