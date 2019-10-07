extends Control

signal play_pressed

func _on_TextureButton_pressed():
	emit_signal("play_pressed")
