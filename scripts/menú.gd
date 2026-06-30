extends Control
@onready var krits_label = $Krits
@onready var runas_label = $Runas

func _process(_delta):
	krits_label.text = ": " + str(GameManager.krits_totales)
	runas_label.text = ": " + str(GameManager.runas)

func _on_jugar_button_pressed():
	AudioManager.play_menu_boton1()
	if GameManager.selected_character < GameManager.personajes_desbloqueados.size() and not GameManager.personajes_desbloqueados[GameManager.selected_character]:
		for i in GameManager.personajes_desbloqueados.size():
			if GameManager.personajes_desbloqueados[i]:
				GameManager.selected_character = i
				break
	get_tree().change_scene_to_file("res://escenas/gameplay.tscn")

func _on_tienda_button_pressed():
	AudioManager.play_menu_boton2()
	get_tree().change_scene_to_file("res://escenas/tienda.tscn")
	
func _on_config_button_pressed():
	AudioManager.play_menu_boton2()
	get_tree().change_scene_to_file("res://escenas/config.tscn")

func _on_logros_button_pressed():
	AudioManager.play_menu_boton2()
	get_tree().change_scene_to_file("res://escenas/logros.tscn")
	
func _on_info_button_pressed():
	AudioManager.play_menu_boton1()
	print("info")
