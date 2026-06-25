extends Control

var current_character := 0

var characters = [
	{

		"portrait": preload("res://Arte/pj1.png")
	},
	{

		"portrait": preload("res://Arte/pj2.png")
	},

]

@onready var image = $CharacterImage


func _ready():
	update_character()

func update_character():
	var character = characters[current_character]

	image.texture = character.portrait


func _on_left_button_pressed():
	current_character -= 1

	if current_character < 0:
		current_character = characters.size() - 1

	update_character()

func _on_right_button_pressed():
	current_character += 1

	if current_character >= characters.size():
		current_character = 0

	update_character()

func get_selected_character():
	return characters[current_character]
