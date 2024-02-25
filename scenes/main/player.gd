extends Node


var _zero_fill: String = "%02d"

enum Difficulty { CASUAL, NORMAL, HARD, IMPOSSIBLE }

# Difficulty
const DIFFICULTY_DEFAULT: Dictionary = {
	Difficulty.CASUAL: { 'text': 'CASUAL', 'armor': 1, 'hp': 5, 'gold': 5, 'food': 6 },
	Difficulty.NORMAL: { 'text': 'NORMAL', 'armor': 0, 'hp': 5, 'gold': 3, 'food': 6 },
	Difficulty.HARD: { 'text': 'HARD', 'armor': 0, 'hp': 4, 'gold': 2, 'food': 3 },
	Difficulty.IMPOSSIBLE: { 'text': 'IMPOSSIBLE', 'armor': 0, 'hp': 3, 'gold': 1, 'food': 3 },
}

var difficulty: Difficulty = Difficulty.NORMAL

# XP by Rank
const RANK: Array[Dictionary] = [
	{ 'rank': 4, 'xp': 36 },
	{ 'rank': 3, 'xp': 18 },
	{ 'rank': 2, 'xp': 6 },
	{ 'rank': 1, 'xp': 0 }
]

var boss_slayed: int = 0

# 戦闘中フラグ
var no_heal: bool = false

# Treasureカードのモンスター討伐判定用
var is_slayed_monsters: bool = false

# Treasureカード使用時に通常時なのかボス戦後のなのかの判別用
var is_after_boss_flag: bool = false

var hp: int = 0:
	set(next_value):
		hp = next_value
		hp = limit_calculation(hp, 20)
		get_node('../Main/Game/Header/HP/Number').text = _zero_fill % hp


var gold: int = 0:
	set(next_value):
		gold = next_value
		gold = limit_calculation(gold, 20)
		get_node('../Main/Game/Header/Gold/Number').text = _zero_fill % gold


var food: int = 0:
	set(next_value):
		food = next_value
		if food < 0: hp += -2
		food = limit_calculation(food, 6)
		get_node('../Main/Game/Header/Food/Number').text = _zero_fill % food


var armor: int = 0:
	set(next_value):
		armor = next_value
		armor = limit_calculation(armor, 5)
		get_node('../Main/Game/Header/Armor/Number').text = _zero_fill % armor


var xp: int = 0:
	set(next_value):
		xp = next_value
		if xp < 0: xp = 0

		var _rank: Array[Dictionary] = RANK.filter(func(item: Dictionary) -> bool: return item.xp <= xp)
		rank = _rank[0]['rank']

		if xp > 36: hp += 1

		get_node('../Main/Game/Header/Rank').text = str("Rank %d" % rank)
		get_node('../Main/Game/Header/XP/Number').text = _zero_fill % xp


var rank: int = 0


func rank_up(add_xp: int) -> bool:
	if rank >= 4: return false

	var _rank: Array[Dictionary] = RANK.filter(func(item: Dictionary) -> bool: return item.rank == rank + 1)
	var _result: bool = true if _rank[0]['xp'] <= xp + add_xp else false

	return _result


func rank_down(lost_xp: int) -> bool:
	if rank <= 1: return false

	var _rank: Array[Dictionary] = RANK.filter(func(item: Dictionary) -> bool: return item.rank == rank)
	var _result: bool = true if _rank[0]['xp'] > xp + lost_xp else false

	return _result


var spell_fire: int = 0:
	set(next_value):
		spell_fire = next_value

		var _set_color: Color = Color('#ffffff') if spell_fire else Color('#808080')
		var _set_max: bool = true if spell_fire >= 2 else false

		get_node('../Main/Game/Header/FireSpell/Max').visible = _set_max
		get_node('../Main/Game/Header/FireSpell').modulate = _set_color


var spell_ice: int = 0:
	set(next_value):
		spell_ice = next_value

		var _set_color: Color = Color('#ffffff') if spell_ice else Color('#808080')
		var _set_max: bool = true if spell_ice >= 2 else false

		get_node('../Main/Game/Header/IceSpell/Max').visible = _set_max
		get_node('../Main/Game/Header/IceSpell').modulate = _set_color


var spell_poison: int = 0:
	set(next_value):
		spell_poison = next_value

		var _set_color: Color = Color('#ffffff') if spell_poison else Color('#808080')
		var _set_max: bool = true if spell_poison >= 2 else false

		get_node('../Main/Game/Header/PoisonSpell/Max').visible = _set_max
		get_node('../Main/Game/Header/PoisonSpell').modulate = _set_color


var spell_heal: int = 0:
	set(next_value):
		spell_heal = next_value

		var _set_color: Color = Color('#ffffff') if spell_heal else Color('#808080')
		var _set_max: bool = true if spell_heal >= 2 else false

		get_node('../Main/Game/Header/HealSpell/Max').visible = _set_max
		get_node('../Main/Game/Header/HealSpell').modulate = _set_color


# 魔法は種類を問わず合計2個まで、同じ種類で2個でも、違う種類で1個ずつでも可
func spell_limit() -> int:
	var _num_of_spells: int = spell_fire + spell_ice + spell_poison + spell_heal
	return _num_of_spells


var area: int = 0:
	set(next_value):
		area = next_value

		var _level: Array[Dictionary] = Global.DUNGEON_LEVEL.filter(func(item: Dictionary) -> bool: return item.rank <= area)

		get_node('../Main/Game/BackGround').texture = load(_level[0]['image'])
		get_node('../Main/EndScreen/BackGround').texture = load(_level[0]['image'])

		level = _level[0]['level']
		var _level_format: String = "%s - Area %02d"
		get_node('../Main/Game/Footer/Level').text = _level_format % [_level[0]['text'], area]


var level: int = 0


func _ready() -> void:
	get_node('../Main/Game/Header/HealSpell').pressed.connect(use_heal_spell)


func use_heal_spell() -> void:
	if not spell_heal or no_heal: return

	hp += 8
	spell_heal += -1


func limit_calculation(current: int, limit: int) -> int:
	if current < 0:
		return 0
	elif current > limit:
		return limit
	else:
		return current


func reset_status() -> void:
	hp = DIFFICULTY_DEFAULT[difficulty]['hp']
	gold = DIFFICULTY_DEFAULT[difficulty]['gold']
	food = DIFFICULTY_DEFAULT[difficulty]['food']
	armor = DIFFICULTY_DEFAULT[difficulty]['armor']
	xp = 0

	spell_fire = 0
	spell_ice = 0
	spell_poison = 0
	spell_heal = 0

	area = 1
	boss_slayed = 0
	is_slayed_monsters = false
