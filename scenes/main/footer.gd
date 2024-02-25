extends Node2D

signal show_map


func _on_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		show_map.emit()
