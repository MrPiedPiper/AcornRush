extends Node2D

var moveAmount = 64
onready var tween = $Tween
var playerTweenDuration = .125 #Seconds
var bufferedMovement = null
var isMovingPlayer = false

func _init():
	
	pass

func _process(delta):
	if  !isMovingPlayer and bufferedMovement != null:
		move_player(bufferedMovement)
		bufferedMovement = null

func _on_Player_move_player(moveDir):
	#If it can move, do. Otherwise, set the buffer and return.
	if isMovingPlayer:
		#TODO: Don't move diagonally
		bufferedMovement = moveDir
		return
	move_player(moveDir)

func move_player(moveDir):
	#TODO Replace with an actual check
	if false:
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
	print(str(moveDir))
	tween.start()

func _on_Tween_tween_completed(object, key):
	if object == $Player:
		isMovingPlayer = false






















