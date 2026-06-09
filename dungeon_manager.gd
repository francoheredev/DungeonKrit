extends Node

@export var sala1_scene: PackedScene
@export var sala2_scene: PackedScene
@export var sala3_scene: PackedScene

@export var enemigo_scene: PackedScene
@export var escena_sombra: PackedScene
@export var tiempo_telegraph := 0.8

# ⏳ NUEVO: delay entre salas
@export var delay_cambio_sala := 0.8

var sala_actual := 1
var enemigos_vivos := 0
var puede_cambiar_sala := true

@onready var sala_actual_node = $"../SalaActual"


func _ready():
	print("DungeonManager iniciado")
	cargar_sala()


func enemigo_muerto():
	enemigos_vivos -= 1

	print("Enemigos restantes: ", enemigos_vivos)

	if enemigos_vivos <= 0 and puede_cambiar_sala:
		puede_cambiar_sala = false
		await get_tree().create_timer(delay_cambio_sala).timeout
		siguiente_sala()


func siguiente_sala():
	sala_actual += 1
	print("Pasando a sala ", sala_actual)
	cargar_sala()


func cargar_sala():
	# reset control
	puede_cambiar_sala = true

	# limpiar sala anterior
	for hijo in sala_actual_node.get_children():
		hijo.queue_free()

	var escena_sala: PackedScene = null

	match sala_actual:
		1:
			escena_sala = sala1_scene
		2:
			escena_sala = sala2_scene
		3:
			escena_sala = sala3_scene
		_:
			print("Dungeon completado")
			return

	if escena_sala == null:
		print("ERROR: Sala no asignada")
		return

	var sala = escena_sala.instantiate()
	sala_actual_node.add_child(sala)

	print("Sala cargada: ", sala.name)

	generar_enemigos(sala)


func generar_enemigos(sala):
	if not sala.has_node("Rutas"):
		print("ERROR: No existe nodo Rutas")
		return

	var rutas = sala.get_node("Rutas").get_children()

	var cantidad_enemigos := 1

	match sala_actual:
		1:
			cantidad_enemigos = 1
		2:
			cantidad_enemigos = 2
		3:
			cantidad_enemigos = 2

	enemigos_vivos = cantidad_enemigos

	for i in range(min(cantidad_enemigos, rutas.size())):
		var ruta = rutas[i]

		if not ruta.has_node("MarkerA"):
			continue

		if not ruta.has_node("MarkerB"):
			continue

		var marker_a = ruta.get_node("MarkerA")
		var marker_b = ruta.get_node("MarkerB")

		spawn_enemigo_con_telegraph(marker_a, marker_b)


func spawn_enemigo_con_telegraph(marker_a, marker_b):
	var sombra = escena_sombra.instantiate()
	sala_actual_node.add_child(sombra)

	sombra.global_position = marker_a.global_position
	sombra.scale = Vector2.ZERO

	var tween = get_tree().create_tween()
	tween.tween_property(sombra, "scale", Vector2(1, 1), tiempo_telegraph)

	call_deferred("_finalizar_spawn", marker_a, marker_b, sombra)


func _finalizar_spawn(marker_a, marker_b, sombra):
	await get_tree().create_timer(tiempo_telegraph).timeout

	var enemigo = enemigo_scene.instantiate()
	sala_actual_node.add_child(enemigo)

	enemigo.global_position = marker_a.global_position
	enemigo.add_to_group("enemigos")

	if enemigo.has_method("configurar_ruta"):
		enemigo.configurar_ruta(marker_a, marker_b)

	sombra.queue_free()
