extends Node2D

var moveAmount = 64
onready var tween = $Tween
var playerTweenDuration = .125 #Seconds
var bufferedMovement = Vector2()

func _init():
	
	pass

func _process(delta):
	if bufferedMovement != Vector2.ZERO:
		move_player(bufferedMovement)
		bufferedMovement = Vector2()
		print("Buffer used")

func _on_Player_move_player(moveDir):
	#If it can move, do. Otherwise, return.
	if tween.is_active():
		bufferedMovement = moveDir
		return
	#TODO Replace with an actual check
	if true:
		move_player(moveDir)

func move_player(moveDir):
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