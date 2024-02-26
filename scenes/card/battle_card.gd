extends Card
class_name BattleCard

# 処理順は、通常ダメージ -> 追加攻撃 ->　毒ダメージ -> 魔法

var level: int = Player.level - 1

var monster_hp: int
var monster_attack: int

var critical_dices: Array[int]

var is_frozon: bool = false
var is_poison: bool = false

enum Flags { NONE, ATTACK_TURN, CRITICAL_ATTACK, CRITICAL_CHOICE, CRITICAL_FAILED, POISON_DAMAGE, SPELL_TURN, DEFENCE_TURN, DEFEATED_ENEMY, GET_XP, RANK_UP, BATTLE_END }
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
			Flags.CRITICAL_ATTACK:
				await hide_message()
				show_message(tr('CHANCE_ADDITIONAL_ATTACK'))
				phase_flag = Flags.CRITICAL_CHOICE
			Flags.CRITICAL_CHOICE:
				await hide_message()
				set_critical()
			Flags.POISON_DAMAGE:
				await hide_message()

				if is_poison:
					poison_damage()
				else:
					spell_turn()

			Flags.SPELL_TURN:
				await hide_message()
				spell_turn()
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
			Player.hp += _damage * - 1
			CardAnimeNode.play('camera_shake')
			await CardAnimeNode.animation_finished

		show_message(tr('TOOK_DAMAGE') % _damage)

	phase_flag = Flags.ATTACK_TURN


func attack() -> void:
	await remove_buttons()

	var _dices: Array[int] = []

	for i in Player.rank:
		var _dice: int = randi() % 6

		_dice = _dice + 1 if _dice > 0 else 0
		_dices.append(_dice)

	var _normal_dices: Array[int] = _dices.filter(func(item: int) -> bool: return item < 6)
	critical_dices = _dices.filter(func(item: int) -> bool: return item == 6)

	var _result: int = _normal_dices.reduce(attack_damage) if _normal_dices.size() else 0
	attack_run(_result, critical_dices.size())


func attack_run(result: int, is_critical: bool) -> void:
	if result <= 0:
		show_message(tr('ATTACK_FAILED'))
		phase_flag = Flags.POISON_DAMAGE
		return

	enemy_damages(result)

	if monster_hp < 1:
		phase_flag = Flags.DEFEATED_ENEMY
	elif is_critical:
		phase_flag = Flags.CRITICAL_ATTACK
	else:
		phase_flag = Flags.POISON_DAMAGE


func enemy_damages(result: int) -> void:
	monster_hp += result * - 1

	CardAnimeNode.play('card_shake')
	await CardAnimeNode.animation_finished

	show_message(tr('DEAL_DAMAGE') % result)
	change_progress_bar()


func set_critical() -> void:
	set_buttons(tr('ADDITIONAL_ATTACK_YES'), critical_attack.bind(true), Global.TWO_POSITIONS[0])
	set_buttons(tr('ADDITIONAL_ATTACK_NO'), critical_attack.bind(false), Global.TWO_POSITIONS[1])
	CardAnimeNode.play('button_in')


func critical_attack(is_critical: bool) -> void:
	await remove_buttons()

	var _result: int = critical_dices.reduce(attack_damage)

	if is_critical:
		for i in critical_dices.size():
			var _additional_dice: int = randi() % 6

			if _additional_dice == 0:
				_result += -6
			else:
				_result += _additional_dice + 1

	if _result <= 0:
		show_message(tr('CRITICAL_FAILED'))
	else:
		enemy_damages(_result)

	phase_flag = Flags.DEFEATED_ENEMY if monster_hp < 1 else Flags.POISON_DAMAGE


func poison_damage() -> void:
	monster_hp += -5

	CardAnimeNode.play('card_shake')
	await CardAnimeNode.animation_finished

	show_message(tr('DEAL_POSITION_DAMAGE'))

	change_progress_bar()
	phase_flag = Flags.DEFEATED_ENEMY if monster_hp < 1 else Flags.SPELL_TURN


func spell_turn() -> void:
	var _spell_count: int = Player.spell_fire + Player.spell_ice + Player.spell_poison + Player.spell_heal
	if not _spell_count:
		deffence()
		return

	set_buttons(tr('USE_SPELL'), set_spell.bind(false), Global.TWO_POSITIONS[0])
	set_buttons(tr('NO_SPELL_USE'), set_spell.bind(true), Global.TWO_POSITIONS[1])

	CardAnimeNode.play('button_in')


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
			change_progress_bar()

			CardAnimeNode.play('card_shake')
			await CardAnimeNode.animation_finished

			show_message(tr('DEAL_DAMAGE') % 8)

			phase_flag = Flags.DEFEATED_ENEMY if monster_hp < 1 else Flags.DEFENCE_TURN
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
