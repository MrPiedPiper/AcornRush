extends Node2D

signal move_player

var moveDir = Vector2()

func _init():
	pass

func _process(delta):
	moveDir = Vector2()
	if Input.is_action_just_pressed("ui_left"):
		moveDir.x -= 1
	if Input.is_action_just_pressed("ui_right"):
		moveDir.x += 1
	if Input.is_action_just_pressed("ui_up"):
		moveDir.y -= 1
	if Input.is_action_just_pressed("ui_down"):
		moveDir.y += 1
	if moveDir != Vector2.ZERO:
		move(moveDir)

func move(moveDir):
	emit_signal("move_player",moveDir)


















