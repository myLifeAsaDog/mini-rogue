extends Node2D

@onready var AnimeNode: AnimationPlayer = get_node('../AnimationPlayer')


func _ready() -> void:
	var _credit: String = ''

	_credit += "[p]MINI ROGUE on Godot[/p]"
	_credit += "[p]\n[/p]"
	_credit += "[p]this game based on mini rogue[/p]"
	_credit += "[p]A 9-Card Print-and-Play Game version 1.2.1[/p]"
	_credit += "[p]https://boardgamegeek.com/boardgame/311715/mini-rogue[/p]"
	_credit += "[p]\n[/p]"
	_credit += "[p]Game Design[/p]"
	_credit += "[p]\n[/p]"
	_credit += "[p]Paolo Di Stefano[/p]"
	_credit += "[p]Gabriel Gendron[/p]"
	_credit += "[p]\n[/p]"
	_credit += "[p]Open Source Licenses[/p]"
	_credit += "[p]\n[/p]"
	_credit += "[p]%s[/p]" % Engine.get_license_text()
	_credit += "[p]\n[/p]"
	_credit += "[p]Third Party Licenses[/p]"
	_credit += "[p]\n[/p]"
	_credit += "[p]Portions of this software are copyright © %d-%d The FreeType Project (www.freetype.org). All rights reserved.[/p]" % [1996, 2023]
	_credit += "[p]\n[/p]"
	_credit += "[p]Copyright (c) 2002-2020 Lee Salzman[/p]"
	_credit += "[p]\n[/p]"
	_credit += 'Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:'
	_credit += "[p]\n[/p]"
	_credit += "[p]The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.[/p]"
	_credit += "[p]\n[/p]"
	_credit += 'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.'

	$CreditLabel.text = _credit


func _on_credits_button_pressed() -> void:
	AnimeNode.play('credits_show')


func _on_close_button_pressed() -> void:
	AnimeNode.play('credits_hide')
