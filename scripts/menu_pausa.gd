extends Control

func _ready():
	visible = false

func _mostrar():
	visible = true
	$"../BlurOverlay".visible = true

func _ocultar():
	visible = false
	$"../BlurOverlay".visible = false

func _on_continuar_button_pressed():
	get_tree().paused = false
	_ocultar()
	$"../PausaButton".visible = true

func _on_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://escenas/menú.tscn")
