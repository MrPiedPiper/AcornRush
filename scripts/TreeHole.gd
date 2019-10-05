extends Node2D

signal hit_food

func _on_Area2D_area_entered(area):
	if area.owner.is_in_group("Food"):
		emit_signal("hit_food", area.owner)
