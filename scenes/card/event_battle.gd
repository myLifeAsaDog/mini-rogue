extends BattleCard


@onready var EventBattleNode: Node = $EventBattleCard
@onready var VitalBarNode: Node = $ProgressBar

var monster: Dictionary = { 'name': tr('MONSTER'), 'image': 'res://assets/cards/Card_Monster.png', 'reward': { 'xp': 2 }}


func _ready() -> void:
	Player.no_heal = false

	var _texture: CompressedTexture2D = load(monster.image)
	EventBattleNode.texture = _texture

	var _dice: int = randi() % 6
	monster_hp = Player.area + _dice + 1
	monster_attack = Player.level * 2

	VitalBarNode.max_value = float(monster_hp)
	VitalBarNode.value = float(monster_hp)

	CardInformationNode.text = monster.name
	CardAnimeNode.play('card_and_info_in')


func change_progress_bar() -> void:
	VitalBarNode.value = float(monster_hp)


func get_xp() -> void:
	var _xp: int = monster.reward.xp
	var _rank_up: bool = true if Player.rank_up(_xp) else false

	show_message("XP +%d" % _xp)
	Player.xp += _xp

	phase_flag = Flags.RANK_UP if _rank_up else Flags.BATTLE_END


func battle_end() -> void:
	Player.no_heal = false
	Player.is_slayed_monsters = true

	card_resolved(self, 'card_and_info_out', '')
