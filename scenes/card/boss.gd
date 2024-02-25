extends Card


var is_clicked: bool = false


func _ready() -> void:
	CardInformationNode.text = tr('ENCOUNT_BOSS')
	CardAnimeNode.play('card_and_info_in')


func _on_input(event: InputEvent) -> void:
	if is_clicked: return

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		is_clicked = true
		card_resolved(self, 'card_and_info_out', 'BossBattleNode')
