extends Control

var characters = [
	{ portrait = preload("res://Arte/pj1.png") },
	{ portrait = preload("res://Arte/pj2.png") },
]

@onready var image = $CharacterImage

func _ready():
	GameManager.selected_character = 0
	update_character()

func update_character():
	var idx = GameManager.selected_character
	image.texture = characters[idx].portrait

func _on_left_button_pressed():
	GameManager.selected_character = (GameManager.selected_character - 1 + characters.size()) % characters.size()
	update_character()

func _on_right_button_pressed():
	GameManager.selected_character = (GameManager.selected_character + 1) % characters.size()
	update_character()
