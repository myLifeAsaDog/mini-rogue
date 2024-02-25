extends Card
class_name BattleCard


var level: int = Player.level - 1

var monster_hp: int
var monster_attack: int

var critical_failed_result: int = 0

var is_frozon: bool = false
var is_poison: bool = false

enum Flags { NONE, ATTACK_TURN, CRITICAL_FAILED, SPELL_TURN, DEFENCE_TURN, DEFEATED_ENEMY, GET_XP, RANK_UP, BATTLE_END }
var phase_flag: Flags = Flags.ATTACK_TURN


func _on_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		match phase_flag:
			Flags.ATTACK_TURN:
				await hide_message()

				if Player.hp < 1:
					card_resolved(self, 'card_and_info_out', 'GameOverNode')
					return

				set_buttons(tr('ATTACK'), attack, Global.ONE_POSITION)
				CardAnimeNode.play('button_in')
			Flags.CRITICAL_FAILED:
				await hide_message()
				attack_run(critical_failed_result)
			Flags.SPELL_TURN:
				await hide_message()

				var _spell_count: int = Player.spell_fire + Player.spell_ice + Player.spell_poison + Player.spell_heal
				if not _spell_count:
					deffence()
					return

				set_buttons(tr('USE_SPELL'), set_spell.bind(false), Global.TWO_POSITIONS[0])
				set_buttons(tr('NO_SPELL_USE'), set_spell.bind(true), Global.TWO_POSITIONS[1])
				
				CardAnimeNode.play('button_in')
			Flags.DEFENCE_TURN:
				await hide_message()
				deffence()
			Flags.DEFEATED_ENEMY:
				await hide_message()
				defeated_enemy()
			Flags.GET_XP:
				await hide_message()
				get_xp()
			Flags.RANK_UP:
				await hide_message()
				show_message(tr('RANK_UP'))
				phase_flag = Flags.BATTLE_END
			Flags.BATTLE_END:
				battle_end()


# 処理は子クラスで実装する
func change_progress_bar() -> void: pass
func get_xp() -> void: pass
func battle_end() -> void: pass


func deffence() -> void:
	var _attack: int = monster_attack - Player.armor
	var _damage: int = _attack if _attack > 0 else 0

	if is_frozon:
		show_message(tr('ENEMY_FROZEN'))
		is_frozon = false
	else:
		if _damage > 0:
			Player.hp += _damage * -1
			CardAnimeNode.play('camera_shake')
			await CardAnimeNode.animation_finished

		show_message(tr('TOOK_DAMAGE') % _damage) 

	phase_flag = Flags.ATTACK_TURN


func attack() -> void:
	await remove_buttons()

	var _dices: Array[int] = []
	var _is_critical: bool

	for i in Player.rank:
		var _dice: int = randi() % 6
		_is_critical = _dice == 5

		_dice = _dice + 1 if _dice > 0 else 0
		_dices.append(_dice)

	if _is_critical:
		set_buttons(tr('ADDITIONAL_ATTACK_YES'), critical_attack.bind(true, _dices), Global.TWO_POSITIONS[0])
		set_buttons(tr('ADDITIONAL_ATTACK_NO'), critical_attack.bind(false, _dices), Global.TWO_POSITIONS[1])
		CardAnimeNode.play('button_in')
	else:
		var _result: int = _dices.reduce(attack_damage)
		attack_run(_result)


func critical_attack(is_critical: bool, dices: Array[int]) -> void:
	await remove_buttons()

	var _is_critical_fail: bool = false

	var _result: int = dices.reduce(attack_damage)
	var _re_roll: Array[int] = dices.filter(func(item: int) -> bool:return item == 6)

	if is_critical:
		for i in _re_roll.size():
			var _additional_dice: int = randi() % 6

			if _additional_dice == 0: 
				_result += -6
				_is_critical_fail = true
			else:
				_result += _additional_dice + 1

	if _is_critical_fail and _result > 0:
		critical_fail(_result)
	else:
		attack_run(_result)


func critical_fail(result: int) -> void:
	critical_failed_result = result
	show_message(tr('CRITICAL_FAILED'))
	phase_flag = Flags.CRITICAL_FAILED


func attack_run(result: int) -> void:
	if result <= 0:
		show_message(tr('ATTACK_FAILED'))
		phase_flag = Flags.SPELL_TURN
		return

	critical_failed_result = 0

	monster_hp += result * -1

	CardAnimeNode.play('card_shake')
	await CardAnimeNode.animation_finished

	if is_poison:
		monster_hp += -5
		result += 5
		show_message(tr('DEAL_DAMAGE_WITH_POISON') % result)
	else:
		show_message(tr('DEAL_DAMAGE') % result)

	change_progress_bar()
	phase_flag = Flags.DEFEATED_ENEMY if monster_hp < 1 else Flags.SPELL_TURN


func attack_damage(accum: int, item: int) -> int:
	return accum + item


func defeated_enemy() -> void:
	show_message(tr('DEFEAT_ENEMY'))

	phase_flag = Flags.GET_XP


func set_spell(is_cancel: bool) -> void:
	await remove_buttons()

	if is_cancel:
		phase_flag = Flags.DEFENCE_TURN
		deffence()
		return

	# 持っている魔法の「種類」（数ではない）
	var _own_spells: Array[Dictionary] = []

	for _spell in Global.SPELLS:
		if Player.get(_spell.status):
			_own_spells.append(_spell)


	var _position: Array[Vector2] = Global.TWO_POSITIONS if _own_spells.size() == 1 else Global.THREE_POSITIONS
	var _iterator: int = 0

	for _spell in _own_spells:
		set_buttons(tr(_spell.text), use_spell.bind(_spell.status), _position[_iterator])
		_iterator += 1

	set_buttons(tr('CANCEL'), use_spell.bind('NONE'), _position[_iterator])
	CardAnimeNode.play('button_in')


func use_spell(magic_id: String) -> void:
	await remove_buttons()

	match magic_id:
		'spell_fire':
			if not Player.spell_fire: 
				show_message(tr('NO_SPELLS'))
				return

			monster_hp += -8
			Player.spell_fire += -1

			CardAnimeNode.play('card_shake')
			await CardAnimeNode.animation_finished

			show_message(tr('DEAL_DAMAGE') % 8)
			phase_flag = Flags.DEFENCE_TURN
		'spell_ice':
			if not Player.spell_ice:
				show_message(tr('NO_SPELLS'))
				return

			is_frozon = true
			Player.spell_ice += -1

			show_message(tr('FROZE_ENEMY'))
			phase_flag = Flags.DEFENCE_TURN
		'spell_poison':
			if not Player.spell_poison:
				show_message(tr('NO_SPELLS'))
				return

			is_poison = true
			Player.spell_poison += -1

			show_message(tr('POISONED_ENEMY'))
			phase_flag = Flags.DEFENCE_TURN
		'spell_heal':
			if not Player.spell_heal:
				show_message(tr('NO_SPELLS'))
				return

			Player.hp += 8
			Player.spell_heal += -1
			show_message(tr('HEAL_8_HP'))
			phase_flag = Flags.DEFENCE_TURN
		_:
			phase_flag = Flags.DEFENCE_TURN
			deffence()
