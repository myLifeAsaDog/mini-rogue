extends Card


enum Flags { NONE, NEXT_LEVEL, LOST_FOOD }
var resolve_flag: Flags = Flags.NEXT_LEVEL


func _ready() -> void:
	var _message: String

	if Game.BOSS_AREA.find(Player.area) == -1:
		_message = tr('GOTO_NEXT_AREA')
	else:
		$NextAreaCard.texture = load('res://assets/cards/Card_NextLevel.png')
		_message = tr('GOTO_NEXT_LEVEL')


	CardInformationNode.text = _message
	CardAnimeNode.play('card_and_info_in')


func _on_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		match resolve_flag:
			Flags.NEXT_LEVEL:
				hide_message()

				var _message: String = tr('LOST_1_FOOD') if Player.food > 0 else tr('LOST_2_HP')
				Player.food += -1

				show_message(_message)

				if Player.hp < 1:
					card_resolved(self, 'card_and_info_out', 'GameOverNode')
					return

				resolve_flag = Flags.LOST_FOOD
			Flags.LOST_FOOD:
				card_resolved(self, 'card_and_info_out', '')
