extends Card


enum TradeFlag { BUY, SELL }

var is_merchant_flag: bool = false

var BUY_PRODUCTS: Array[Dictionary] = [
	{ 'text': tr('RATION'), 'status': 'food', 'effect': 1, 'cost': - 1, 'limit': 6, 'event': buy_product.bind(0) },
	{ 'text': tr('HEALTH_POTION'), 'status': 'hp', 'effect': 1, 'cost': - 1, 'limit': 20, 'event': buy_product.bind(1) },
	{ 'text': tr('BIG_HEALTH_POTION'), 'status': 'hp', 'effect': 4, 'cost': - 3, 'limit': 20, 'event': buy_product.bind(2) },
	{ 'text': tr('ARMOR_PIECE'), 'status': 'armor', 'effect': 1, 'cost': - 6, 'limit': 5, 'event': buy_product.bind(3) },
	{ 'text': tr('ANY_SPELL'), 'status': 'spells', 'effect': 1, 'cost': - 8, 'event': set_spell.bind(TradeFlag.BUY) },
]

var SELL_PRODUCTS: Array[Dictionary] = [
	{ 'text': tr('ARMOR_PIECE'), 'status': 'armor', 'effect': - 1, 'cost': 3, 'event': sell_product.bind(0) },
	{ 'text': tr('ANY_SPELL'), 'status': 'spells', 'effect': - 1, 'cost': 4, 'event': set_spell.bind(TradeFlag.SELL) },
]


func _ready() -> void:
	CardInformationNode.text = tr('ENCOUNT_MERCHANT')
	CardAnimeNode.play('card_and_info_in')
	await CardAnimeNode.animation_finished


func _on_input(event: InputEvent) -> void:
	if is_merchant_flag: return
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		start_merchant()


func start_merchant() -> void:
	hide_message()

	await CardAnimeNode.animation_finished

	set_buttons(tr('BUY'), set_products.bind(TradeFlag.BUY), Global.THREE_POSITIONS[0])
	set_buttons(tr('SELL'), set_products.bind(TradeFlag.SELL), Global.THREE_POSITIONS[1])
	set_buttons(tr('LEAVE_MERCHANT'), leave_merchant, Global.THREE_POSITIONS[2])
	CardAnimeNode.play('button_in')

	is_merchant_flag = true


# 売買する商品のボタンを生成する
func set_products(trade: TradeFlag) -> void:
	await remove_buttons()

	var _product_array: Array[Dictionary] = BUY_PRODUCTS if trade == TradeFlag.BUY else SELL_PRODUCTS

	var _iterator: int = 0
	for product in _product_array:
		var _cost: int = product.cost * - 1 if trade == TradeFlag.BUY else product.cost
		var _label: String = "%s %d Gold" % [product.text, _cost]
		var _position: Vector2 = Global.SIX_POSITIONS[_iterator] if trade == TradeFlag.BUY else Global.THREE_POSITIONS[_iterator]
		set_buttons(_label, product.event, _position)
		_iterator += 1

	var _last_position: Vector2 = Global.SIX_POSITIONS[_iterator] if trade == TradeFlag.BUY else Global.THREE_POSITIONS[_iterator]
	set_buttons(tr('CANCEL'), trade_cansel, _last_position)
	CardAnimeNode.play('button_in')


func buy_product(product_id: int) -> void:
	await remove_buttons()

	is_merchant_flag = false
	var _product: Dictionary = BUY_PRODUCTS[product_id]

	# 所持金が足りない場合
	if Player.gold < _product.cost * - 1:
		show_message(tr('NOT_MONEY'))
		return

	var _status: int = Player.get(_product.status)

	# 既に上限値に達している場合
	if _status == _product.limit:
		show_message(tr('PARAMETER_LIMIT') % _product.status.to_upper())
		return

	var _message: String = "%s + %d" % [_product.status.to_upper(), _product.effect]
	show_message(_message)

	Player.gold += _product.cost

	Player.set(_product.status, _status + _product.effect)


func sell_product(product_id: int) -> void:
	await remove_buttons()

	is_merchant_flag = false
	var _product: Dictionary = SELL_PRODUCTS[product_id]
	var _status: int = Player.get(_product.status)

	if _status < _product.effect * - 1:
		var _message: String = tr('NOT_HAVE_ANY') % _product.text
		show_message(_message)
		return

	Player.set(_product.status, _status + _product.effect)
	Player.gold += _product.cost

	show_message(tr('GET_X_GOLD') % _product.cost)


func set_spell(trade: TradeFlag) -> void:
	await remove_buttons()

	var _iterator: int = 0

	for spell in Global.SPELLS:
		var _cost: int = spell.buy * - 1 if trade == TradeFlag.BUY else spell.sell
		var _label: String = "%s %d Gold" % [tr(spell.text), _cost]
		var _event: Callable = buy_spell.bind(_iterator) if trade == TradeFlag.BUY else sell_spell.bind(_iterator)

		set_buttons(_label, _event, Global.FIVE_POSIITONS[_iterator])

		_iterator += 1

	var _position: Vector2 = Global.FIVE_POSIITONS[_iterator]
	set_buttons(tr('CANCEL'), trade_cansel, _position)
	CardAnimeNode.play('button_in')


func buy_spell(product_id: int) -> void:
	await remove_buttons()

	is_merchant_flag = false
	var _spell: Dictionary = Global.SPELLS[product_id]

	if Player.gold < _spell.buy * - 1:
		show_message(tr('NOT_MONEY'))
		return

	# 既に上限値に達している場合
	if Player.spell_limit() >= 2:
		show_message(tr('SPELL_LIMIT'))
		return

	Player.gold += _spell.buy

	var _status: int = Player.get(_spell.status)
	Player.set(_spell.status, _status + 1)

	show_message(tr('GET_X') % tr(_spell.text))


func sell_spell(product_id: int) -> void:
	await remove_buttons()

	is_merchant_flag = false
	var _spell: Dictionary = Global.SPELLS[product_id]
	var _status: int = Player.get(_spell.status)

	if _status < 1:
		show_message(tr('NOT_HAVE_ANY_SPELLS'))
		return

	Player.set(_spell.status, _status - 1)
	Player.gold += _spell.sell

	show_message(tr('GET_X_GOLD') % _spell.sell)


func trade_cansel() -> void:
	await remove_buttons()
	start_merchant()


func leave_merchant() -> void:
	is_merchant_flag = true
	await remove_buttons()
	card_resolved(self, 'card_and_info_out', '')
