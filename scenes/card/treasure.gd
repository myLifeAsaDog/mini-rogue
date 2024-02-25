extends Card


enum Flags { NONE, GET_GOLD, SPELL_LIMIT, DROP_SPELL, DISCARD_SPELL, ADD_XP, RANK_UP, EXTRA_ITEM }
var treasure_flag: Flags = Flags.NONE

var TREASURE: Array[Dictionary] = [
	{ 'text': tr('ARMOR_PIECE'), 'status': 'armor', 'value': 1 },
	{ 'text': tr('BETTER_WEAPON'), 'status': 'xp', 'value': 2 },
	{ 'text': tr('SPELL_FIRE'), 'status': 'spell_fire', 'value': 1 },
	{ 'text': tr('SPELL_ICE'), 'status': 'spell_ice', 'value': 1 },
	{ 'text': tr('SPELL_POISON'), 'status': 'spell_poison', 'value': 1 },
	{ 'text': tr('SPELL_HEAL'), 'status': 'spell_heal', 'value': 1 }
]


func _ready() -> void:
	# ボス戦後のアイテム入手時用
	if Player.is_after_boss_flag:
		CardAnimeNode.play('card_slide_in')
		await CardAnimeNode.animation_finished
		Player.is_after_boss_flag = false
		get_extra_item()
	else:
		CardInformationNode.text = check_get_gold()
		CardAnimeNode.play('card_and_info_in')
		await CardAnimeNode.animation_finished
		treasure_flag = Flags.GET_GOLD


func _on_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:

		match treasure_flag:
			Flags.GET_GOLD:
				hide_message()
				check_extra_item()
			Flags.SPELL_LIMIT:
				spell_limit()
			Flags.DROP_SPELL:
				drop_spell()
			Flags.DISCARD_SPELL:
				check_spells()
			Flags.ADD_XP:
				show_message("XP + 2")
				treasure_flag = Flags.EXTRA_ITEM
			Flags.RANK_UP:
				show_message(tr('RANK_UP'))
				treasure_flag = Flags.EXTRA_ITEM
			Flags.EXTRA_ITEM:
				await hide_message()
				card_resolved(self, 'card_and_info_out', '')


func check_extra_item() -> void:
	var _dice: int = randi() % 6

	if not _dice >= 4:
		card_resolved(self, 'card_and_info_out', '')
		return

	get_extra_item()


func get_extra_item() -> void:
	var _dice: int = randi() % 6

	# ランクが上がるかどうか
	var _rank_up: bool = true if _dice == 1 and Player.rank_up(TREASURE[_dice]['value']) else false

	var _stats: int = Player.get(TREASURE[_dice]['status'])
	Player.set(TREASURE[_dice]['status'], _stats + TREASURE[_dice]['value'])

	show_message(tr('FOUND_X') % TREASURE[_dice]['text'])

	if _rank_up:
		treasure_flag = Flags.RANK_UP
	elif _dice == 1:
		treasure_flag = Flags.ADD_XP
	elif _dice >= 2 and Player.spell_limit() > 2:
		treasure_flag = Flags.SPELL_LIMIT
	else:
		treasure_flag = Flags.EXTRA_ITEM



# 呪文が所持数を超えている場合
func spell_limit() -> void:
	await hide_message()

	show_message(tr('SPELL_LIMIT'))
	treasure_flag = Flags.DROP_SPELL


# 呪文を捨てる必要がある旨を表示
func drop_spell() -> void:
	await hide_message()

	show_message(tr('SPELL_DISCARD'))
	treasure_flag = Flags.DISCARD_SPELL


# 捨てる呪文を選択
func check_spells() -> void:
	Player.no_heal = true
	await hide_message()

	var _spells: Array[Dictionary] = Global.SPELLS.filter(func(item: Dictionary) -> bool: return Player.get(item.status) != 0)

	var _iterator: int = 0
	for _spell in _spells:
		set_buttons(tr(_spell.text), select_discard_spell.bind(_spell), Global.FOUR_POSITIONS[_iterator])
		_iterator += 1

	CardAnimeNode.play('button_in')


# 呪文を捨てた
func select_discard_spell(spell: Dictionary) -> void:
	await remove_buttons()

	var _status: int = Player.get(spell.status)
	Player.set(spell.status, _status - 1)

	show_message(tr('DROP_SPELL') % tr(spell.text))
	Player.no_heal = false
	treasure_flag = Flags.EXTRA_ITEM


func check_get_gold() -> String:
	# このエリアでモンスターを討伐しているかどうか
	var _gold: int = 2 if Player.is_slayed_monsters else 1

	Player.gold += _gold

	var _text_format: String = tr('FOUND_GOLD')
	return _text_format % _gold
