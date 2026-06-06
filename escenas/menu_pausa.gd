extends Control

func _ready():
	visible = false

func _on_continuar_button_pressed():
	get_tree().paused = false
	visible = false
	$"../PausaButton".visible = true

func _on_reiniciar_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://escenas/menú.tscn")
