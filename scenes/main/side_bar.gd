extends Node2D


@onready var AnimeNode: AnimationPlayer = $AnimationPlayer
@onready var StartScreenAnimeNode: AnimationPlayer = get_node('../StartScreen/AnimationPlayer')
@onready var LanguageNode: Label = $Menu / Launguage


func _ready() -> void:
	get_node('../Game/Header/OptionButton').pressed.connect(show_sidebar)
	change_locale()


func change_locale() -> void:
	LanguageNode.text = "Language: %s" % TranslationServer.get_locale()


func show_sidebar() -> void:
	AnimeNode.play('sidebar_slide_in')
	await AnimeNode.animation_finished


func hide_slidebar() -> void:
	AnimeNode.play('sidebar_slide_out')
	await AnimeNode.animation_finished


func _on_overlay_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		await hide_slidebar()


func _on_back_to_title_pressed() -> void:
	hide_slidebar()

	StartScreenAnimeNode.play('back_to_title')
	await StartScreenAnimeNode.animation_finished


func change_language(locale: String) -> void:
	TranslationServer.set_locale(locale)
	change_locale()
	hide_slidebar()


func _on_en_pressed() -> void:
	change_language('en')


func _on_jp_pressed() -> void:
	change_language('ja')
