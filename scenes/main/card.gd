extends Node
class_name Card

@onready var CardAnimeNode: Node = get_node('../../AnimationPlayer')
@onready var CardInformationNode: Node = get_node('../../Information')
@onready var CardButtonNode: Node = get_node('../../ButtonContainer')

@onready var CardContainerNode: Node = get_node('../../../CardContainer/Cards')
@onready var GameEndNode: Node = get_node('../../../../EndScreen')

var ButtonNode: PackedScene = preload('res://scenes/main/button.tscn')

signal resolved_card(card_node: Node2D, next_node: String)


func _ready() -> void:
	CardAnimeNode.play('card_slide_in')
	await CardAnimeNode.animation_finished


func skill_check() -> bool:
	var _dice: int = randi() % 6

	return Player.rank > _dice


func show_message(message: String) -> void:
	CardInformationNode.text = message
	CardAnimeNode.play('show_info')
	await CardAnimeNode.animation_finished


func hide_message() -> void:
	CardAnimeNode.play('hide_info')
	await CardAnimeNode.animation_finished


func set_buttons(button_text: String, event_name: Callable, button_pos: Vector2) -> void:
	var _new_button: Button = ButtonNode.instantiate()
	_new_button.text = button_text
	_new_button.position = button_pos
	_new_button.pressed.connect(event_name)
	CardButtonNode.add_child(_new_button)


func remove_buttons() -> Node:
	CardAnimeNode.play('button_out')
	await CardAnimeNode.animation_finished

	var _buttons: Array[Node] = CardButtonNode.get_children()

	for node in _buttons:
		node.queue_free()

	return self


func card_resolved(self_node: Card, animation_name: String, next_node: String) -> void:
	CardAnimeNode.play(animation_name)
	await CardAnimeNode.animation_finished
	resolved_card.emit(self_node, next_node)


func end_screen_on(card_node: Card) -> void:
	card_node.queue_free()

	GameEndNode.set_victory_point()
	GameEndNode.get_node('AnimationPlayer').play('end_screen_in')
