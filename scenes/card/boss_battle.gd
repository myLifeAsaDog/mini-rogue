extends BattleCard


@onready var BossBattleNode: Node = $BossBattleCard
@onready var VitalBarNode: Node = $ProgressBar

var _boss: Dictionary

var BOSS: Array[Dictionary] = [
	{ 'name': tr('UNDEAD_GIANT'), 'hp': 10, 'attack': 3, 'image': 'res://assets/cards/boss/Undead Giant.png', 'reward': { 'gold': 2, 'xp': 1 }},
	{ 'name': tr('SKELETON_LORD'), 'hp': 15, 'attack': 5, 'image': 'res://assets/cards/boss/Skeleton Lord.png', 'reward': { 'gold': 2, 'xp': 3 }},
	{ 'name': tr('UNDEAD_LORD'), 'hp': 20, 'attack': 7, 'image': 'res://assets/cards/boss/Undead Lord.png', 'reward': { 'gold': 3, 'xp': 4 }},
	{ 'name': tr('SERPENT_DEMON'), 'hp': 25, 'attack': 9, 'image': 'res://assets/cards/boss/Serpent Demon.png', 'reward': { 'gold': 3, 'xp': 5 }},
	{ 'name': tr('OG_REMAINS'), 'hp': 30, 'attack': 12, 'image': 'res://assets/cards/boss/Ogs Remain.png' }
]


func _ready() -> void:
	Player.no_heal = true

	_boss = BOSS[level]
	var _texture: CompressedTexture2D = load(_boss.image)
	BossBattleNode.texture = _texture

	monster_hp = _boss.hp
	monster_attack = _boss.attack

	VitalBarNode.max_value = float(monster_hp)
	VitalBarNode.value = float(monster_hp)

	CardInformationNode.text = _boss.name
	CardAnimeNode.play('card_and_info_in')


func change_progress_bar() -> void:
	VitalBarNode.value = float(monster_hp)


func get_xp() -> void:
	if Player.area >= 14:
		card_resolved(self, 'card_and_info_out', 'GameClearNode')
		return

	var _gold: int = _boss.reward.gold
	var _xp: int = _boss.reward.xp

	show_message(tr('GOLD_AND_XP') % [_gold, _xp])

	var _rank_up: bool = true if Player.rank_up(_xp) else false

	Player.gold += _gold
	Player.xp += _xp

	phase_flag = Flags.RANK_UP if _rank_up else Flags.BATTLE_END


func battle_end() -> void:
	Player.no_heal = false
	Player.boss_slayed += 1
	Player.is_after_boss_flag = true

	card_resolved(self, 'card_and_info_out', 'TreasureCardNode')
