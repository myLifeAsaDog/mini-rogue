extends Card


func _ready() -> void:
	CardInformationNode.text = tr('GAME_OVER')
	CardAnimeNode.play('card_and_info_in')


func _on_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		hide_message()
		end_screen_on(self)
