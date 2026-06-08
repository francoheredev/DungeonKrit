extends Node

@export var sala1_scene: PackedScene
@export var sala2_scene: PackedScene
@export var sala3_scene: PackedScene

@export var enemigo_scene: PackedScene

var dungeon_actual := 1
var sala_actual := 1
var enemigos_vivos := 0

@onready var sala_actual_node = $"../SalaActual"

func _ready():
	print("DungeonManager iniciado")
	cargar_sala()

func enemigo_muerto():
	enemigos_vivos -= 1

	print("Enemigos restantes: ", enemigos_vivos)

	if enemigos_vivos <= 0:
		siguiente_sala()

func siguiente_sala():
	sala_actual += 1

	print("Pasando a sala ", sala_actual)

	cargar_sala()

func cargar_sala():
	# Limpiar sala anterior
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
			print("Dungeon 1 completado")
			return

	if escena_sala == null:
		print("ERROR: No hay escena asignada para la sala ", sala_actual)
		return

	var sala = escena_sala.instantiate()

	sala_actual_node.add_child(sala)

	print("Sala cargada: ", sala.name)

	generar_enemigos(sala)

func generar_enemigos(sala):
	if not sala.has_node("Rutas"):
		print("ERROR: La sala no tiene un nodo llamado 'Rutas'")
		return

	var rutas = sala.get_node("Rutas").get_children()

	print("Rutas encontradas: ", rutas.size())

	var cantidad_enemigos := 1

	match sala_actual:
		1:
			cantidad_enemigos = 1
		2:
			cantidad_enemigos = 2
		3:
			cantidad_enemigos = 3

	for i in range(min(cantidad_enemigos, rutas.size())):
		var ruta = rutas[i]

		if not ruta.has_node("MarkerA"):
			print("ERROR: ", ruta.name, " no tiene MarkerA")
			continue

		if not ruta.has_node("MarkerB"):
			print("ERROR: ", ruta.name, " no tiene MarkerB")
			continue

		var marker_a = ruta.get_node("MarkerA")
		var marker_b = ruta.get_node("MarkerB")

		var enemigo = enemigo_scene.instantiate()

		sala_actual_node.add_child(enemigo)

		enemigo.global_position = marker_a.global_position

		if enemigo.has_method("configurar_ruta"):
			enemigo.configurar_ruta(marker_a, marker_b)

		print("Enemigo generado en ", marker_a.global_position)
