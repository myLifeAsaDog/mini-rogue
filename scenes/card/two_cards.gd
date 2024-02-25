extends Card

var ROOM_CARD: Array[Dictionary] = [
	{ 'name': tr('MONSTER'), 'image': 'res://assets/cards/Card_Monster.png' },
	{ 'name': tr('TRAP'), 'image': 'res://assets/cards/Card_Trap.png' },
	{ 'name': tr('EVENTS'), 'image': 'res://assets/cards/Card_Events.png' },
	{ 'name': tr('TREASURE'), 'image': 'res://assets/cards/Card_Treasure.png' },
	{ 'name': tr('MERCHANT'), 'image': 'res://assets/cards/Card_Merchant.png' },
	{ 'name': tr('RESTING'), 'image': 'res://assets/cards/Card_Resting.png' }
]

@onready var first_id: int = get_meta('firstcard')
@onready var second_id: int = get_meta('secondcard')


func _ready() -> void:
	var _first_card: Dictionary = ROOM_CARD[first_id]
	var _second_card: Dictionary = ROOM_CARD[second_id]

	$FirstCard.texture = load(_first_card.image)
	$SecondCard.texture = load(_second_card.image)

	set_buttons(_first_card.name, on_first_button, Global.TWO_POSITIONS[0])
	set_buttons(_second_card.name, on_second_button, Global.TWO_POSITIONS[1])

	CardAnimeNode.play('card_and_button_in')


func card_selected(selected_id: int) -> void:
	await remove_buttons()

	Game.room_deck.push_back(selected_id)

	card_resolved(self, 'card_slide_out', '')


func on_first_button() -> void:
	card_selected(first_id)


func on_second_button() -> void:
	card_selected(second_id)
