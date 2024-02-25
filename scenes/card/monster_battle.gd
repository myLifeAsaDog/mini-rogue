extends BattleCard


@onready var MonsterBattleNode: Node = $MonsterBattleCard
@onready var VitalBarNode: Node = $ProgressBar

var _monster: Dictionary

var MONSTER: Array[Dictionary] = [
	{ 'name': tr('UNDEAD_SOLDIER'), 'attack': 2, 'image': 'res://assets/cards/monster/Undead Soldier.png', 'reward': { 'xp': 1 } },
	{ 'name': tr('SKELETON'), 'attack': 4, 'image': 'res://assets/cards/monster/Skeleton.png', 'reward': { 'xp': 1 } },
	{ 'name': tr('UNDEAD_KNIGHT'), 'attack': 6, 'image': 'res://assets/cards/monster/Undead Knight.png', 'reward': { 'xp': 2 } },
	{ 'name': tr('SERPENT_KNIGHT'), 'attack': 8, 'image': 'res://assets/cards/monster/Serpent Knight.png', 'reward': { 'xp': 2 } },
	{ 'name': tr('SANCTUM_GUARD'), 'attack': 10, 'image': 'res://assets/cards/monster/Sactum Gard.png', 'reward': { 'xp': 3 } }
]


func _ready() -> void:
	Player.no_heal = true

	_monster = MONSTER[level]
	var _texture: CompressedTexture2D = load(_monster.image)
	MonsterBattleNode.texture = _texture

	var _dice: int = randi() % 6
	monster_hp = Player.area + _dice + 1
	monster_attack = _monster.attack

	VitalBarNode.max_value = float(monster_hp)
	VitalBarNode.value = float(monster_hp)

	CardInformationNode.text = _monster.name
	CardAnimeNode.play('card_and_info_in')


func change_progress_bar() -> void:
	VitalBarNode.value = float(monster_hp)


func get_xp() -> void:
	var _xp: int = _monster.reward.xp
	var _rank_up: bool = Player.rank_up(_xp)

	show_message("XP +%d" % _xp)
	Player.xp += _xp

	phase_flag = Flags.RANK_UP if _rank_up else Flags.BATTLE_END


func battle_end() -> void:
	Player.no_heal = false
	Player.is_slayed_monsters = true

	card_resolved(self, 'card_and_info_out', '')
