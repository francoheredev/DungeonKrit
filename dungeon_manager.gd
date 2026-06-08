extends Node

@export var sala1_scene: PackedScene
@export var enemigo_scene: PackedScene

var dungeon_actual := 1
var sala_actual := 1
var enemigos_vivos := 0

@onready var sala_actual_node = $"../SalaActual"

func _ready():
	cargar_sala()

func enemigo_muerto():
	enemigos_vivos -= 1

	if enemigos_vivos <= 0:
		siguiente_sala()

func siguiente_sala():
	sala_actual += 1

	print("Pasando a sala ", sala_actual)

	cargar_sala()

func cargar_sala():
	# Borra la sala anterior
	for hijo in sala_actual_node.get_children():
		hijo.queue_free()

	# Crea la sala nueva
	var sala = sala1_scene.instantiate()

	sala_actual_node.add_child(sala)

	generar_enemigos(sala)

func generar_enemigos(sala):
	var rutas = sala.get_node("Rutas").get_children()

	for ruta in rutas:
		var enemigo = enemigo_scene.instantiate()

		get_parent().add_child(enemigo)

		var marker_a = ruta.get_node("MarkerA")
		var marker_b = ruta.get_node("MarkerB")

		enemigo.global_position = marker_a.global_position

		if enemigo.has_method("configurar_ruta"):
			enemigo.configurar_ruta(marker_a, marker_b)
