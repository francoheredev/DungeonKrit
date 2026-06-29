extends Control

var characters = [
	{ portrait = preload("res://Arte/pj1.png") },
	{ portrait = preload("res://Arte/pj2.png") },
	{ portrait = preload("res://Arte/pj3.png") },
	{ portrait = preload("res://Arte/pj4.png") },
]

@onready var image = $CharacterImage
var lock_sprite: Sprite2D

func _ready():
	lock_sprite = Sprite2D.new()
	lock_sprite.texture = preload("res://Arte/lock ico.png")
	lock_sprite.position = image.position + image.size / 2
	lock_sprite.scale = Vector2(0.08, 0.08)
	add_child(lock_sprite)
	lock_sprite.move_to_front()

	GameManager.selected_character = 0
	update_character()

func update_character():
	var idx = GameManager.selected_character
	image.texture = characters[idx].portrait
	var unlocked = idx < GameManager.personajes_desbloqueados.size() and GameManager.personajes_desbloqueados[idx]
	image.modulate = Color(1, 1, 1, 0.3) if not unlocked else Color(1, 1, 1, 1)
	lock_sprite.visible = not unlocked

func _on_left_button_pressed():
	GameManager.selected_character = (GameManager.selected_character - 1 + characters.size()) % characters.size()
	update_character()

func _on_right_button_pressed():
	GameManager.selected_character = (GameManager.selected_character + 1) % characters.size()
	update_character()
