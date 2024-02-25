extends Node2D

@onready var CardContainerNode: Node = get_node('../Game/CardContainer/Cards')
@onready var ButtonContainerNode: Node = get_node('../Game/CardContainer/ButtonContainer')
@onready var AnimeNode: AnimationPlayer = $AnimationPlayer

var is_clicked: bool = false

signal set_difficulty


func _ready() -> void:
	self.show()
	Player.area = 1


func game_start() -> void:
	var _reset_nodes: Array[Node] = [CardContainerNode, ButtonContainerNode]

	for _container in _reset_nodes:
		if _container.get_child_count():
			var _nodes: Array[Node] = _container.get_children()

			for node in _nodes:
				_container.remove_child(node)

	Player.reset_status()

	AnimeNode.play('game_start')
	await AnimeNode.animation_finished

	is_clicked = false
	set_difficulty.emit()


func _on_card_input(event: InputEvent) -> void:
	if is_clicked: return

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		is_clicked = true
		Player.difficulty = Player.Difficulty.NORMAL
		game_start()


func _on_casual_pressed() -> void:
	Player.difficulty = Player.Difficulty.CASUAL
	game_start()


func _on_normal_pressed() -> void:
	Player.difficulty = Player.Difficulty.NORMAL
	game_start()


func _on_hard_pressed() -> void:
	Player.difficulty = Player.Difficulty.HARD
	game_start()


func _on_impossible_pressed() -> void:
	Player.difficulty = Player.Difficulty.IMPOSSIBLE
	game_start()


func _on_credits_pressed() -> void:
	pass # Replace with function body.
