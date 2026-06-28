extends Node

@export var salas_pool_a: Array[PackedScene] = []
@export var salas_pool_b: Array[PackedScene] = []
@export var salas_boss_a: Array[PackedScene] = []
@export var salas_boss_b: Array[PackedScene] = []
@export var escenas_enemigo_a: Array[PackedScene] = []
@export var escenas_enemigo_b: Array[PackedScene] = []
@export var escenas_boss_a: Array[PackedScene] = []
@export var escenas_boss_b: Array[PackedScene] = []
@export var fondos: Array[Texture2D] = []
@export var escena_sombra_a: PackedScene
@export var escena_sombra_b: PackedScene
@export var escena_sombra_boss_a: PackedScene
@export var escena_sombra_boss_b: PackedScene
@export var tiempo_telegraph := 0.8
@export var delay_cambio_sala := 0.8

var ciclo_actual := 0
var desplazamiento_tema := 0
var posicion_en_ciclo := 0
var salas_usadas_a: Array[int] = []
var salas_usadas_b: Array[int] = []
var enemigos_vivos := 0
var puede_cambiar_sala := true

const PROGRESION = [
	{salas=3, enemigos=1},
	{salas=3, enemigos=2},
	{salas=3, enemigos=3},
	{salas=3, enemigos=1},
	{salas=3, enemigos=2},
	{salas=3, enemigos=3},
]

@onready var sala_actual_node = $"../SalaActual"
@onready var fondo_node = $"../fondo"

func _ready():
	desplazamiento_tema = randi() % 2
	cambiar_fondo_segun_tema()
	cargar_sala()

func tema() -> int:
	return (ciclo_actual + desplazamiento_tema) % 2

func cambiar_fondo_segun_tema():
	if fondos.is_empty():
		return
	var idx = mini(tema(), fondos.size() - 1)
	fondo_node.texture = fondos[idx]
	if idx == 1:
		fondo_node.scale = Vector2(1.05, 1.05)
	else:
		fondo_node.scale = Vector2(1, 1)

func enemigo_muerto():
	enemigos_vivos -= 1
	if enemigos_vivos <= 0 and puede_cambiar_sala:
		puede_cambiar_sala = false
		await get_tree().create_timer(delay_cambio_sala).timeout
		siguiente_sala()

func salas_por_ciclo() -> int:
	if ciclo_actual < PROGRESION.size():
		return PROGRESION[ciclo_actual].salas
	var inc = ciclo_actual - 5
	return 3 + ceil(inc / 3.0)

func enemigos_por_sala() -> int:
	if ciclo_actual < PROGRESION.size():
		return PROGRESION[ciclo_actual].enemigos
	return 1 + (ciclo_actual - 6) % 3

func siguiente_sala():
	posicion_en_ciclo += 1
	if posicion_en_ciclo > salas_por_ciclo():
		posicion_en_ciclo = 0
		ciclo_actual += 1
		cambiar_fondo_segun_tema()
	cargar_sala()

func cargar_sala():
	puede_cambiar_sala = true

	for hijo in sala_actual_node.get_children():
		hijo.queue_free()

	var N = salas_por_ciclo()
	var escena_sala: PackedScene = null
	var es_boss := false

	if posicion_en_ciclo < N:
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

func _pool_normal() -> Array[PackedScene]:
	return salas_pool_a if tema() == 0 else salas_pool_b

func _pool_boss_salas() -> Array[PackedScene]:
	return salas_boss_a if tema() == 0 else salas_boss_b

func _pool_enemigos() -> Array[PackedScene]:
	return escenas_enemigo_a if tema() == 0 else escenas_enemigo_b

func _pool_boss_tipos() -> Array[PackedScene]:
	return escenas_boss_a if tema() == 0 else escenas_boss_b

func _sombra() -> PackedScene:
	return escena_sombra_a if tema() == 0 else escena_sombra_b

func _sombra_boss() -> PackedScene:
	return escena_sombra_boss_a if tema() == 0 else escena_sombra_boss_b

func _usadas() -> Array[int]:
	return salas_usadas_a if tema() == 0 else salas_usadas_b

func _marcar_usada(idx: int):
	if tema() == 0:
		salas_usadas_a.append(idx)
	else:
		salas_usadas_b.append(idx)

func _limpiar_usadas():
	if tema() == 0:
		salas_usadas_a.clear()
	else:
		salas_usadas_b.clear()

func _elegir_sala_normal() -> PackedScene:
	var pool = _pool_normal()
	var usadas = _usadas()

	var disponibles: Array[int] = []
	for i in pool.size():
		if not i in usadas:
			disponibles.append(i)

	if disponibles.is_empty():
		_limpiar_usadas()
		for i in pool.size():
			disponibles.append(i)

	var idx = disponibles.pick_random()
	_marcar_usada(idx)
	return pool[idx]

func _elegir_sala_boss() -> PackedScene:
	var pool = _pool_boss_salas()
	if pool.is_empty():
		return null
	var idx = ciclo_actual % pool.size()
	return pool[idx]

func generar_enemigos(sala):
	if not sala.has_node("Rutas"):
		return

	var rutas = sala.get_node("Rutas").get_children()
	var cantidad = mini(enemigos_por_sala(), rutas.size())
	var pool_enemigos = _pool_enemigos()

	enemigos_vivos = cantidad

	var rutas_disponibles = rutas.duplicate()
	rutas_disponibles.shuffle()

	for i in cantidad:
		var ruta = rutas_disponibles[i]
		if not ruta.has_node("MarkerA") or not ruta.has_node("MarkerB"):
			continue
		var marker_a = ruta.get_node("MarkerA")
		var marker_b = ruta.get_node("MarkerB")
		var escena = pool_enemigos[randi() % pool_enemigos.size()]
		spawn_enemigo_con_telegraph(marker_a, marker_b, escena, _sombra(), false)

func generar_boss(sala):
	if not sala.has_node("Rutas"):
		return

	var rutas = sala.get_node("Rutas").get_children()
	enemigos_vivos = 1

	if rutas.is_empty():
		return

	rutas.shuffle()
	var ruta = rutas[0]
	if not ruta.has_node("MarkerA") or not ruta.has_node("MarkerB"):
		return

	var marker_a = ruta.get_node("MarkerA")
	var marker_b = ruta.get_node("MarkerB")

	var pool_boss = _pool_boss_tipos()
	var escena = pool_boss[randi() % pool_boss.size()] if not pool_boss.is_empty() else null

	if escena == null:
		return

	spawn_enemigo_con_telegraph(marker_a, marker_b, escena, _sombra_boss(), true)

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

	if enemigo.has_method("configurar_ruta") and ciclo_actual >= 3:
		enemigo.configurar_ruta(marker_a, marker_b)
		if randi() % 2 == 0:
			enemigo.indice_actual = 1
			enemigo.global_position = marker_b.global_position

	if ciclo_actual >= 3:
		var factor = 1.0 + (ciclo_actual - 2) * 0.08
		if "velocidad_movimiento" in enemigo:
			enemigo.velocidad_movimiento *= factor
		if "velocidad_base_rotacion" in enemigo:
			enemigo.velocidad_base_rotacion *= factor

	if es_boss and enemigo.has_method("recibir_dano") and "vida_maxima" in enemigo:
		var escala_hp = 1.0 + ciclo_actual * 0.3
		enemigo.vida_maxima = int(enemigo.vida_maxima * escala_hp)
		enemigo.vida = enemigo.vida_maxima

	sombra.queue_free()
