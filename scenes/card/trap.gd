extends Card


const TRAP: Array[Dictionary] = [
	{ 'text': 'MOLD_MIASMA', 'status': 'food', 'value': - 1 },
	{ 'text': 'TRIP_WIRE', 'status': 'gold', 'value': - 1 },
	{ 'text': 'ACID_MIST', 'status': 'armor', 'value': - 1 },
	{ 'text': 'SPRING_BLADES', 'status': 'hp', 'value': - 1 },
	{ 'text': 'AMNESIA_GAS', 'status': 'xp', 'value': - 1 },
	{ 'text': 'PIT', 'status': 'hp', 'value': - 2 }
]

enum Flags { NONE, ACTIVE_TRAP, BUTTON_ON, RANK_DOWN, RESOLVE_TRAP }
var trap_flag: Flags = Flags.NONE


func _ready() -> void:
	CardInformationNode.text = tr('TRAP_FOUND')
	CardAnimeNode.play('card_and_info_in')


func _on_input(event: InputEvent) -> void:
	if trap_flag == Flags.BUTTON_ON: return

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		match trap_flag:
			Flags.NONE:
				hide_message()
				await CardAnimeNode.animation_finished

				set_buttons(tr('TRAP_TRY'), avoid_trap, Global.ONE_POSITION)
				CardAnimeNode.play('button_in')
				trap_flag = Flags.BUTTON_ON
			Flags.ACTIVE_TRAP:
				await hide_message()
				result_trap()
			Flags.RANK_DOWN:
				await hide_message()
				show_message(tr('RANK_DOWN'))
				trap_flag = Flags.RESOLVE_TRAP
			Flags.RESOLVE_TRAP:
				await hide_message()
				var _next_node: String = 'GameOverNode' if Player.hp < 1 else ''
				card_resolved(self, 'card_and_info_out', _next_node)


func avoid_trap() -> void:
	await remove_buttons()

	if skill_check():
		show_message(tr('TRAP_DODGE'))
		trap_flag = Flags.RESOLVE_TRAP
	else:
		show_message(tr('TRAP_FAILED'))
		trap_flag = Flags.ACTIVE_TRAP


func result_trap() -> void:
	var _dice: int = randi() % 6
	var _trap: Dictionary = TRAP[_dice]

	# 落とし穴で落ちる先
	if _dice == 5:
		match Player.area:
			1, 2, 3, 4:
				Player.area += 2
			5, 6, 7, 8, 9, 10:
				Player.area += 3

	# HPが減少する場合は、画面を揺らす
	if _trap.status == 'hp':
		CardAnimeNode.play('camera_shake')
		await CardAnimeNode.animation_finished

	var _rank_down: bool = true if _trap.status == 'xp' and Player.rank_down(_trap.value) else false

	var _status: int = Player.get(_trap.status)
	var _result: int = _status + _trap.value

	Player.set(_trap.status, _result)

	show_message(tr('ACTIVATE_TRAP') % [tr(_trap.text), _trap.status.to_upper(), _trap.value])
	trap_flag = Flags.RANK_DOWN if _rank_down else Flags.RESOLVE_TRAP
