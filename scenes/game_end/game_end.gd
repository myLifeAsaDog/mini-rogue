extends Node2D


@onready var AnimeNode: AnimationPlayer = $AnimationPlayer
@onready var StartScreenAnimeNode: Node = get_node('../StartScreen/AnimationPlayer')


func set_victory_point() -> void:
	var _difficulty: int = Player.difficulty * 10
	var _area_reached: int = Player.area * 3
	var _boss_slayed: int = Player.boss_slayed * 2

	var _rank: int = Player.rank * 2
	var _health: int = Player.hp * 2
	var _gold: int = Player.gold * 2
	var _spells: int = Player.spell_fire + Player.spell_ice + Player.spell_poison + Player.spell_heal
	var _armor: int = Player.armor
	var _food: int = Player.food

	$Control / DifficultyLevel / Number.text = str(_difficulty)
	$Control / AreaReached / Number.text = str(_area_reached)
	$Control / BossSlayed / Number.text = str(_boss_slayed)

	$Control / Rank / Number.text = str(_rank)
	$Control / Health / Number.text = str(_health)
	$Control / Gold / Number.text = str(_gold)
	$Control / Spells / Number.text = str(_spells)
	$Control / Armor / Number.text = str(_armor)
	$Control / Food / Number.text = str(_food)

	$VictoryPoint / Number.text = str(_difficulty + _area_reached + _boss_slayed + _rank + _health + _gold + _spells + _armor + _food)


func _on_back_to_title() -> void:
	AnimeNode.play('end_screen_out')

	StartScreenAnimeNode.play('back_to_title')
	await StartScreenAnimeNode.animation_finished
