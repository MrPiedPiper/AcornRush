extends Control

signal main_menu_pressed
signal play_pressed
signal retry_pressed

func _on_TextureButton_pressed():
	emit_signal("play_pressed")


func _on_TextureButton2_pressed():
	emit_signal("main_menu_pressed")


func _on_TextureButton3_pressed():
	emit_signal("retry_pressed")
