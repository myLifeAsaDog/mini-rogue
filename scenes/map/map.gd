extends Node2D

@onready var _animation: AnimationPlayer = $AnimationPlayer
@onready var ActiveNode: Node = $Active


func _on_show_map() -> void:
	var _area: int = Player.area if Player.area < 14 else 14
	var _area_num: String = str("%02d" % _area)
	ActiveNode.position = get_node(_area_num).position

	_animation.play('slide_in')


func _on_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		_animation.play('slide_out')
