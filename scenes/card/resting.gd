extends Card

enum Flags { NONE, RANK_UP, REST_END }

var rest_flags: Flags = Flags.NONE

var RESTING_EVENTS: Array[Dictionary] = [
	{ 'text': tr('REST_WEAPON'), 'status': 'xp', 'value': 1, 'event': rest_result.bind(0) },
	{ 'text': tr('REST_RATION'), 'status': 'food', 'value': 1, 'event': rest_result.bind(1) },
	{ 'text': tr('REST_HEAL'), 'status': 'hp', 'value': 2, 'event': rest_result.bind(2) }
]


func _ready() -> void:
	var _iterator: int = 0
	for item in RESTING_EVENTS:
		set_buttons(tr(item['text']), item['event'], Global.THREE_POSITIONS[_iterator])
		_iterator += 1

	CardAnimeNode.play('card_and_button_in')


func rest_result(id: int) -> void:
	await remove_buttons()

	var _resting: Dictionary = RESTING_EVENTS[id]
	var _rank_up: bool = true if id == 0 and Player.rank_up(_resting.value) else false

	var _status: int = Player.get(_resting.status)
	Player.set(_resting.status, _status + _resting.value)

	show_message("%s + %d" % [_resting.status.to_upper(), _resting.value])

	rest_flags = Flags.RANK_UP if _rank_up else Flags.REST_END


func _on_input(event: InputEvent) -> void:
	if rest_flags == Flags.NONE: return

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		match rest_flags:
			Flags.RANK_UP:
				await hide_message()
				show_message(tr('RANK_UP'))
				rest_flags = Flags.REST_END
			Flags.REST_END:
				rest_flags = Flags.NONE
				await hide_message()
				card_resolved(self, 'card_slide_out', '')
