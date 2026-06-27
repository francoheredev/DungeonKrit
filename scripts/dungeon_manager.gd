extends Node

@export var salas_normales: Array[PackedScene] = []
@export var salas_boss: Array[PackedScene] = []

@export var enemigo_scene: PackedScene
@export var enemigo_boss_scene: PackedScene
@export var escena_sombra: PackedScene
@export var escena_sombra_boss: PackedScene
@export var tiempo_telegraph := 0.8
@export var delay_cambio_sala := 0.8

var ciclo_actual := 0
var posicion_en_ciclo := 0
var salas_usadas: Array[int] = []
var enemigos_vivos := 0
var puede_cambiar_sala := true

@onready var sala_actual_node = $"../SalaActual"

func _ready():
	cargar_sala()

func enemigo_muerto():
	enemigos_vivos -= 1
	if enemigos_vivos <= 0 and puede_cambiar_sala:
		puede_cambiar_sala = false
		await get_tree().create_timer(delay_cambio_sala).timeout
		siguiente_sala()

func siguiente_sala():
	posicion_en_ciclo += 1
	if posicion_en_ciclo > 3:
		posicion_en_ciclo = 0
		ciclo_actual += 1
	cargar_sala()

func cargar_sala():
	puede_cambiar_sala = true

	for hijo in sala_actual_node.get_children():
		hijo.queue_free()

	var escena_sala: PackedScene = null
	var es_boss := false

	if posicion_en_ciclo < 3:
		escena_sala = _elegir_sala_normal()
	else:
		escena_sala = _elegir_sala_boss()
		es_boss = true

	if escena_sala == null:
		return

	var sala = escena_sala.instantiate()
	sala_actual_node.add_child(sala)

	if es_boss:
		generar_boss(sala)
	else:
		generar_enemigos(sala)

func _elegir_sala_normal() -> PackedScene:
	var disponibles: Array[int] = []
	for i in salas_normales.size():
		if not i in salas_usadas:
			disponibles.append(i)

	if disponibles.is_empty():
		salas_usadas.clear()
		for i in salas_normales.size():
			disponibles.append(i)

	var idx = disponibles.pick_random()
	salas_usadas.append(idx)
	return salas_normales[idx]

func _elegir_sala_boss() -> PackedScene:
	var idx = ciclo_actual % salas_boss.size()
	return salas_boss[idx]

func generar_enemigos(sala):
	if not sala.has_node("Rutas"):
		return

	var rutas = sala.get_node("Rutas").get_children()
	var cantidad = mini(1 + ciclo_actual, rutas.size())

	enemigos_vivos = cantidad

	for i in cantidad:
		var ruta = rutas[i]
		if not ruta.has_node("MarkerA") or not ruta.has_node("MarkerB"):
			continue
		var marker_a = ruta.get_node("MarkerA")
		var marker_b = ruta.get_node("MarkerB")
		spawn_enemigo_con_telegraph(marker_a, marker_b, enemigo_scene, escena_sombra, false)

func generar_boss(sala):
	if not sala.has_node("Rutas"):
		return

	var rutas = sala.get_node("Rutas").get_children()
	enemigos_vivos = 1

	if rutas.is_empty():
		return

	var ruta = rutas[0]
	if not ruta.has_node("MarkerA") or not ruta.has_node("MarkerB"):
		return

	var marker_a = ruta.get_node("MarkerA")
	var marker_b = ruta.get_node("MarkerB")

	spawn_enemigo_con_telegraph(marker_a, marker_b, enemigo_boss_scene, escena_sombra_boss, true)

func spawn_enemigo_con_telegraph(marker_a, marker_b, escena_enemigo, escena_sombra, es_boss := false):
	var sombra = escena_sombra.instantiate()
	sala_actual_node.add_child(sombra)
	sombra.global_position = marker_a.global_position
	sombra.scale = Vector2.ZERO

	var tween = get_tree().create_tween()
	tween.tween_property(sombra, "scale", Vector2(1, 1), tiempo_telegraph)

	call_deferred("_finalizar_spawn", marker_a, marker_b, sombra, escena_enemigo, es_boss)

func _finalizar_spawn(marker_a, marker_b, sombra, escena_enemigo, es_boss):
	await get_tree().create_timer(tiempo_telegraph).timeout

	var enemigo = escena_enemigo.instantiate()
	sala_actual_node.add_child(enemigo)
	enemigo.global_position = marker_a.global_position
	enemigo.add_to_group("enemigos")

	if enemigo.has_method("configurar_ruta"):
		enemigo.configurar_ruta(marker_a, marker_b)

	if es_boss and enemigo.has_method("recibir_dano") and "vida_maxima" in enemigo:
		var escala_hp = 1.0 + ciclo_actual * 0.5
		enemigo.vida_maxima = int(enemigo.vida_maxima * escala_hp)
		enemigo.vida = enemigo.vida_maxima

	sombra.queue_free()
