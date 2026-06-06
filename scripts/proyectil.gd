extends Area2D
 
@export var velocidad := 1200.0
@export var distancia_maxima := 1500.0
@export var dano := 10
@export var offset_entierro := 30.0   # cuántos px se entierra en el enemigo
 
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

	elif area.is_in_group("criticos"):
		golpe_critico(area)

	elif area.is_in_group("enemigos"):
		clavar(area)
 
func clavar(enemigo):
	clavada = true
	velocidad = 0
	GameManager.puntos += 10
 
	if enemigo.has_method("recibir_dano"):
		enemigo.recibir_dano(dano)
 
	# enterrar la flecha hacia el centro del enemigo
	global_position += direccion * offset_entierro
 
	# apuntar al centro del enemigo
	var dir_al_centro = enemigo.global_position - global_position
	var angulo_al_centro = dir_al_centro.angle() + PI / 2
 
	var pos = global_position
	reparent(enemigo)
	global_position = pos
	global_rotation = angulo_al_centro  # rotación global, no relativa
 
	add_to_group("flechas")
 
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador:
		jugador.puede_disparar = true
 
func game_over():
	print("GAME OVER")

	var jugador = get_tree().get_first_node_in_group("jugador")

	if jugador:
		jugador.die()

func golpe_critico(critico):
	var enemigo = critico.get_parent()

	clavada = true
	velocidad = 0

	if enemigo.has_method("recibir_dano"):
		enemigo.recibir_dano(30)

	GameManager.agregar_krit()
	GameManager.puntos += 50
	print("Krits totales: ", GameManager.krits_totales)
	critico.queue_free()

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
