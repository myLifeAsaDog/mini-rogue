extends Resource
class_name Global


enum Spells { FIRE, ICE, POISON, HEAL }

const DUNGEON_LEVEL: Array[Dictionary] = [
	{ 'level': 5, 'text': 'Level 5 Sunken Keep of Og', 'rank': 11, 'image': 'res://assets/background/level_05.png' },
	{ 'level': 4, 'text': 'Level 4 Flaming Underworld', 'rank': 8, 'image': 'res://assets/background/level_04.png' },
	{ 'level': 3, 'text': 'Level 3 Undead Catacombs', 'rank': 5, 'image': 'res://assets/background/level_03.png'},
	{ 'level': 2, 'text': 'Level 2 PoisonusDungeon', 'rank': 3, 'image': 'res://assets/background/level_02.png' },
	{ 'level': 1, 'text': 'Level 1 Black Sewers', 'rank': 1, 'image': 'res://assets/background/level_01.png' }
]

const ONE_POSITION: Vector2 = Vector2(0, 80)
const TWO_POSITIONS: Array[Vector2] = [Vector2(0, 60), Vector2(0, 120)]
const THREE_POSITIONS: Array[Vector2] = [Vector2(0, 20), Vector2(0, 80), Vector2(0, 140)]
const FOUR_POSITIONS: Array[Vector2] = [Vector2(0, 40), Vector2(0, 100), Vector2(0, 160), Vector2(0, 220)]
const FIVE_POSIITONS: Array[Vector2] = [Vector2(0, - 40), Vector2(0, 20), Vector2(0, 80), Vector2(0, 140), Vector2(0, 200)]
const SIX_POSITIONS: Array[Vector2] = [Vector2(0, - 65), Vector2(0, - 5), Vector2(0, 55), Vector2(0, 115), Vector2(0, 175), Vector2(0, 235)]


const SPELLS: Array[Dictionary] = [
	{ 'text': 'SPELL_FIRE', 'status': 'spell_fire', 'buy': - 8, 'sell': 4, 'position': Vector2(0, - 30) },
	{ 'text': 'SPELL_ICE', 'status': 'spell_ice', 'buy': - 8, 'sell': 4, 'position': Vector2(0, 30) },
	{ 'text': 'SPELL_POISON', 'status': 'spell_poison', 'buy': - 8, 'sell': 4, 'position': Vector2(0, 90) },
	{ 'text': 'SPELL_HEAL', 'status': 'spell_heal', 'buy': - 8, 'sell': 4, 'position': Vector2(0, 150) },
]
