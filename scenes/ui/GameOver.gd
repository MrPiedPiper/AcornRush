extends Control

export(Texture) var sadTexture
export(Texture) var okTexture
export(Texture) var happyTexture

signal retry
signal main_menu

func set_score(newScore):
	$MarginContainer/MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/Score.text = str("You got ",newScore," points!")
	if newScore > 2000:
		$MarginContainer/MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/Squirrel.texture = happyTexture
		$MarginContainer/MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/Quip.text = "Plenty for winter. Congrats!"
	elif newScore > 750:
		$MarginContainer/MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/Squirrel.texture = okTexture
		$MarginContainer/MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/Quip.text = "That should be enough c:"
	else:
		$MarginContainer/MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/Squirrel.texture = sadTexture
		$MarginContainer/MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/Quip.text = "That... was a nice effort. Good luck with that."

func _on_TextureButton3_pressed():
	emit_signal("retry")


func _on_TextureButton2_pressed():
	emit_signal("main_menu")
