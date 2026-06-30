extends Area2D

@export var velocidad := 1300.0
@export var distancia_maxima := 1200.0
@export var dano := 10
@export var offset_entierro := 30.0
@export var offset_entierro_critico := 70.0
@export var escena_impacto: PackedScene
@export var escena_impacto_critico: PackedScene
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
		mostrar_impacto_colision()
		destruir()
		game_over()

	elif area.is_in_group("criticos"):
		golpe_critico(area)

	elif area.is_in_group("enemigos"):
		clavar(area)

func clavar(enemigo):
	clavada = true
	velocidad = 0
	GameManager.agregar_puntos(10)

	if enemigo.has_method("recibir_dano"):
		enemigo.recibir_dano(dano, false)
		enemigo.shake(15.0)

	GameManager.registrar_racha_hit()
	GameManager.racha_krits = 0

	global_position += direccion * offset_entierro
	crear_impacto(enemigo)

	var dir_al_centro = enemigo.global_position - global_position
	var angulo_al_centro = dir_al_centro.angle() + PI / 2
	var pos = global_position
	reparent(enemigo)
	global_position = pos
	global_rotation = angulo_al_centro
	add_to_group("flechas")

	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador:
		jugador.puede_disparar = true

func golpe_critico(critico):
	var enemigo = critico.get_parent()
	clavada = true
	velocidad = 0

	var es_boss = enemigo.is_in_group("bosses")

	if enemigo.has_method("recibir_dano"):
		enemigo.recibir_dano(30, true)
		enemigo.shake(15.0)

	if es_boss:
		GameManager.agregar_krit_boss()
	else:
		GameManager.agregar_krit()
	GameManager.registrar_racha_hit()
	GameManager.registrar_racha_krit()
	GameManager.agregar_puntos(50)
	critico.queue_free()

	global_position += direccion * offset_entierro_critico
	crear_impacto_critico(enemigo)
	add_to_group("flechas")

	var dir_al_centro = enemigo.global_position - global_position
	var angulo_al_centro = dir_al_centro.angle() + PI / 2
	var pos = global_position
	reparent(enemigo)
	global_position = pos
	global_rotation = angulo_al_centro

	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador:
		jugador.puede_disparar = true

func crear_impacto(enemigo):
	if escena_impacto == null:
		return
	var impacto = escena_impacto.instantiate()
	enemigo.add_child(impacto)
	impacto.position = enemigo.to_local(global_position)
	impacto.emitting = true

func crear_impacto_critico(enemigo):
	if escena_impacto_critico == null:
		return
	var impacto_critico = escena_impacto_critico.instantiate()
	enemigo.add_child(impacto_critico)
	impacto_critico.position = enemigo.to_local(global_position)
	impacto_critico.emitting = true

func mostrar_impacto_colision():
	var muerte = preload("res://escenas/muerte_jugador.tscn")
	var particulas = muerte.instantiate()
	get_tree().current_scene.add_child(particulas)
	particulas.global_position = global_position
	particulas.emitting = true

func game_over():
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador:
		jugador.die()

func destruir():
	if not clavada:
		GameManager.reset_rachas()
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador:
		jugador.puede_disparar = true
	queue_free()