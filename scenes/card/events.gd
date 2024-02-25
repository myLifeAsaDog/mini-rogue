extends Card


enum Flags { NONE, RANK_UP, EVENT_END }
var events_flag: Flags = Flags.NONE

var is_encount_monster: bool = false

var EVENTS: Array[Dictionary] = [
	{ 'text': tr('FOUND_RATION'), 'status': 'food', 'value': 1 },
	{ 'text': tr('FOUND_POTION'), 'status': 'hp', 'value': 2 },
	{ 'text': tr('FOUND_LOOT'), 'status': 'gold', 'value': 2 },
	{ 'text': tr('FOUND_WHETSTONE'), 'status': 'xp', 'value': 2 },
	{ 'text': tr('FOUND_SHIELD'), 'status': 'armor', 'value': 1 },
	{ 'text': tr('ENCOUNT_MONSTER') }
]


func _ready() -> void:
	set_buttons(tr('RANDOM_EVENT'), set_event, Global.ONE_POSITION)
	CardAnimeNode.play('card_and_button_in')
	await CardAnimeNode.animation_finished


func set_event() -> void:
	await remove_buttons()

	var _dice: int = randi() % 6

	if skill_check():
		set_multi_event(_dice)
	else:
		single_event(_dice)


func single_event(dice: int) -> void:
	var _event: Dictionary = EVENTS[dice]

	if dice == 5:
		is_encount_monster = true
		show_message(_event.text)
		events_flag = Flags.EVENT_END
	else:
		show_message("%s %s + %d" % [_event.text, _event.status.to_upper(), _event.value])

		var _rank_up: bool = true if dice == 3 and Player.rank_up(_event.value) else false
		var _status: int = Player.get(_event.status)
		Player.set(_event.status, _status + _event.value)

		events_flag = Flags.RANK_UP if _rank_up else Flags.EVENT_END


func set_multi_event(dice: int) -> void:
	var _event_list: Array[int]

	match dice:
		0:
			_event_list = [0, 1]
		5:
			_event_list = [4, 5]
		_:
			_event_list = [dice - 1, dice, dice + 1]

	var _iterator: int = 0

	for i in _event_list:
		var _position_y: int = _iterator * 60 + 20 if _event_list.size() == 3 else _iterator * 60 + 40
		set_buttons(EVENTS[i]['text'], selected_event.bind(i), Vector2(0, _position_y))
		_iterator += 1

	CardAnimeNode.play('button_in')


func selected_event(event_id: int) -> void:
	await remove_buttons()
	single_event(event_id)


func _on_input(event: InputEvent) -> void:
	if events_flag == Flags.NONE: return

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		match events_flag:
			Flags.RANK_UP:
				await hide_message()
				show_message(tr('RANK_UP'))
				events_flag = Flags.EVENT_END
			Flags.EVENT_END:
				await hide_message()
				var _next_node: String = 'EventMonsterNode' if is_encount_monster else ''
				card_resolved(self, 'card_and_info_out', _next_node)
