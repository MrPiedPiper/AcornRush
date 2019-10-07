extends Node2D

var isPaused = false
var isInGame = false

var treeScene = preload("res://scenes/Tree.tscn")

func _ready():
	get_tree().paused = true
	createTree()

func createTree():
	var children = $ActiveScene.get_children()
	for i in range(children.size()):
		$ActiveScene.remove_child(children[i])
	var newScene = treeScene.instance()
	newScene.connect("food_changed", self, "_on_Tree_food_changed")
	newScene.connect("time_changed", self, "_on_Tree_time_changed")
	$ActiveScene.add_child(newScene)

func new_game():
	isInGame = true
	isPaused = false
	createTree()
	$UI/PauseMenu.visible = false
	$UI/MainMenu.visible = false
	$UI/PlayUI.visible = true
	get_tree().paused = false
	
func main_menu():
	createTree()
	isInGame = false
	isPaused = false
	$UI/PauseMenu.visible = false
	$UI/MainMenu.visible = true
	$UI/PlayUI.visible = false
	get_tree().paused = true

func pause():
	isPaused = true
	$UI/PauseMenu.visible = true
	$UI/MainMenu.visible = false
	$UI/PlayUI.visible = true
	get_tree().paused = true

func unpause():
	isPaused = false
	$UI/PauseMenu.visible = false
	$UI/MainMenu.visible = false
	$UI/PlayUI.visible = true
	get_tree().paused = false

func retry():
	new_game()

func _on_Tree_food_changed(newScore):
	$UI/PlayUI.set_score(newScore)

func _on_Tree_time_changed(newTime):
	$UI/PlayUI.set_time(newTime)

func _input(event):
	if isInGame and Input.is_action_just_pressed("control_pause"):
		print(isPaused)
		if isPaused:
			unpause()
		else:
			pause()

func _on_MainMenu_play_pressed():
	new_game()

func _on_PauseMenu_main_menu_pressed():
	main_menu()

func _on_PauseMenu_play_pressed():
	unpause()

func _on_PauseMenu_retry_pressed():
	retry()
