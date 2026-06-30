extends Control
@onready var krits_label = $Krits
@onready var runas_label = $Runas
@onready var info_overlay = $InfoOverlay
@onready var info_label = $InfoOverlay/InfoLabel

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
	var idx = GameManager.selected_character
	var data = GameManager.CHARACTER_DATA[idx]
	info_label.text = _info_texto(idx, data)
	info_overlay.visible = true

func _on_cerrar_info_pressed():
	info_overlay.visible = false

func _info_texto(idx: int, data: Dictionary) -> String:
	var t = data.name + "\n\n"
	t += "Velocidad: " + str(data.velocidad) + "\n"
	t += "Apuntado: " + str(data.velocidad_apuntado) + "\n"
	t += "Cooldown: " + str(data.cooldown_disparo) + "s\n"
	t += "Daño: " + str(data.dano) + "\n"
	t += "Vel. Proyectil: " + str(data.velocidad_proyectil) + "\n"
	t += "Alcance: " + str(data.distancia_maxima_proyectil) + "\n\n"
	if data.has("pasiva"):
		var p = data.pasiva
		match p.id:
			"critico_mortal":
				t += "PASIVA: Crítico Mortal\nLos críticos hacen x" + str(p.multiplicador) + " de daño"
			"doble_puntos":
				t += "PASIVA: Puntos Dobles\nObtiene el doble de puntos en cada run"
			"congelar":
					t += "PASIVA: Congelar\n" + str(p.prob * 100) + "% de congelar al enemigo " + str(p.duracion) + "s"
					if p.has("revive_gratis") and p.revive_gratis:
						t += "\n+ 1 revive gratis por run"
			"ejecutar":
					t += "PASIVA: Ejecutar\n" + str(p.prob * 100) + "% de eliminar al instante"
	else:
		t += "SIN PASIVA\nPersonaje base, sin habilidad especial"
	return t
