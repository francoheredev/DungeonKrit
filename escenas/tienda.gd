extends Control

@onready var krits_label = $Krits
@onready var runas_label = $RunasLabel

func _process(_delta):
	krits_label.text = ": " + str(GameManager.krits_totales)
	runas_label.text = ": " + str(GameManager.runas)

func _on_menu_button_pressed():
	get_tree().change_scene_to_file("res://escenas/menú.tscn")
