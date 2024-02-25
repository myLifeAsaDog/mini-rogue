extends Node2D
class_name Game


@onready var CardContainerNode: Node = $CardContainer / Cards

# CardNodes
var MonsterCardNode: PackedScene = preload('res://scenes/card/monster.tscn')
var MonsterBattleNode: PackedScene = preload('res://scenes/card/monster_battle.tscn')
var TreasureCardNode: PackedScene = preload('res://scenes/card/treasure.tscn')
var TrapCardNode: PackedScene = preload('res://scenes/card/trap.tscn')
var MerchantCardNode: PackedScene = preload('res://scenes/card/merchant.tscn')
var RestingCardNode: PackedScene = preload('res://scenes/card/resting.tscn')
var EventsCardNode: PackedScene = preload('res://scenes/card/events.tscn')
var EventMonsterNode: PackedScene = preload('res://scenes/card/event_battle.tscn')
var BossCardNode: PackedScene = preload('res://scenes/card/boss.tscn')
var BossBattleNode: PackedScene = preload('res://scenes/card/boss_battle.tscn')

var FirstCardNode: PackedScene = preload('res://scenes/card/first.tscn')
var TwoCardNode: PackedScene = preload('res://scenes/card/two_cards.tscn')
var NextAreaNode: PackedScene = preload('res://scenes/card/next_area.tscn')
var GameClearNode: PackedScene = preload('res://scenes/card/game_clear.tscn')
var GameOverNode: PackedScene = preload('res://scenes/card/game_over.tscn')

# Dungeon Stats
static var room_deck: Array[int] = []

enum ROOMS { NONE, NOT_VISIT, VISITED }
var room_map: Array[ROOMS] = []
var origin_deck: Array[int] = []

const BOSS_AREA: Array[int] = [2, 4, 7, 10, 14]

signal change_room(room_array: Array[int])


func _on_set_difficulty() -> void:
	$CardContainer / ButtonContainer.hide()
	$CardContainer / Information.hide()
	get_node('../SideBar/Menu/Difficulty').text = "Mode : %s" % Player.DIFFICULTY_DEFAULT[Player.difficulty]['text']

	$RoomMap.room_map_reset()

	add_card(FirstCardNode)
	reset_game()


func reset_game() -> void:
	reset_room_deck()


func reset_room_deck() -> void:
	room_deck = []
	room_map = []

	for i in range(7):
		if not i == 6: room_deck.append(i)
		room_map.append(ROOMS.NOT_VISIT)

	room_deck.shuffle()
	origin_deck = room_deck.duplicate(true)

	if BOSS_AREA.find(Player.area) == -1:
		room_map[6] = ROOMS.NONE
	else:
		room_deck.push_front(6)


func draw_card() -> void:
	var _card_num: int = room_deck.pop_back()
	var _node_array: Array[PackedScene] = [
		MonsterCardNode, TrapCardNode, EventsCardNode, TreasureCardNode,
		MerchantCardNode, RestingCardNode, BossCardNode
	]

	var _none_boss: Array[int] = room_deck.filter(func(item: int) -> bool: return item != 6)

	# Display two cards
	if _none_boss.size() == 4 or _none_boss.size() == 1:
		var _next_card_num: int = room_deck.pop_back()
		add_two_cards(_card_num, _next_card_num)
		return

	check_room_map(_card_num)
	add_card(_node_array[_card_num])


func check_room_map(card_num: int) -> void:
	var _num_of_room: int = 5 - origin_deck.find(card_num)

	if card_num == 6:
		room_map[6] = ROOMS.VISITED
	else:
		room_map[_num_of_room] = ROOMS.VISITED

	change_room.emit(room_map)


func add_card(card_node: PackedScene) -> void:
	var _new_card: Card = card_node.instantiate()

	_new_card.resolved_card.connect(_on_card_resolved)
	CardContainerNode.add_child(_new_card)


func add_two_cards(first_card: int, second_card: int) -> void:
	var _new_card: Node2D = TwoCardNode.instantiate()

	_new_card.set_meta('firstcard', first_card)
	_new_card.set_meta('secondcard', second_card)

	_new_card.resolved_card.connect(_on_card_resolved)
	CardContainerNode.add_child(_new_card)


func _on_card_resolved(card_node: Card, next_node: String) -> void:
	card_node.queue_free()

	if not next_node:
		if room_deck.size():
			draw_card()
		elif Player.area > 14:
			add_card(GameClearNode)
		else:
			add_card(NextAreaNode)
			Player.area += 1
			Player.is_slayed_monsters = false
			reset_room_deck()

	match next_node:
		'GameClearNode':
			add_card(GameClearNode)
		'GameOverNode':
			add_card(GameOverNode)
		'MonsterBattleNode':
			add_card(MonsterBattleNode)
		'EventMonsterNode':
			add_card(EventMonsterNode)
		'BossBattleNode':
			add_card(BossBattleNode)
		'TreasureCardNode':
			add_card(TreasureCardNode)
