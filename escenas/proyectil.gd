extends Area2D

@export var velocidad := 1000.0
@export var distancia_maxima := 1500.0

var posicion_inicial := Vector2.ZERO
var clavada := false
var direccion := Vector2.ZERO

func _ready():
	posicion_inicial = global_position

func _process(delta):
	if clavada:
		return

	global_position += direccion * velocidad * delta

	if global_position.distance_to(posicion_inicial) > distancia_maxima:
		destruir()

func _on_area_entered(area):
	if clavada:
		return

	if area.is_in_group("flechas"):
		game_over()

	elif area.is_in_group("enemigos"):
		clavar(area)

func clavar(enemigo):
	clavada = true
	velocidad = 0

	add_to_group("flechas")

	var pos = global_position
	var rot = global_rotation

	reparent(enemigo)

	global_position = pos
	global_rotation = rot

	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador:
		jugador.puede_disparar = true

func destruir():
	var jugador = get_tree().get_first_node_in_group("jugador")

	if jugador:
		jugador.puede_disparar = true

	queue_free()

func game_over():
	print("GAME OVER")
	var jugador = get_tree().get_first_node_in_group("jugador")

	if jugador:
		jugador.die()
