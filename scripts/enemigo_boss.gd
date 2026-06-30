extends Area2D

@export var velocidad_movimiento: float = 80.0
@export var marcadores: Array[Marker2D] = []
@export var velocidad_base_rotacion: float = 3.0
@export var escena_critico: PackedScene
@export var cantidad_criticos := 4
@export var radio_criticos := 220.0
@export var escena_muerte: PackedScene
@export var escena_muerte_critica: PackedScene
@export var vida_maxima: int = 80

var vida: int
var shake_strength := 0.0
var velocidad_rotacion_actual: float = 0.0
var tiempo_patron: float = 0.0
var indice_actual: int = 0
var en_rabia := false

func _ready():
	vida = vida_maxima
	generar_criticos()

func configurar_ruta(marker_a: Marker2D, marker_b: Marker2D):
	marcadores = [marker_a, marker_b]
	indice_actual = 0
	global_position = marker_a.global_position

func generar_criticos():
	for i in cantidad_criticos:
		var critico = escena_critico.instantiate()
		add_child(critico)
		var angulo = randf_range(0, TAU)
		critico.position = Vector2.RIGHT.rotated(angulo) * radio_criticos

func _process(delta):
	if marcadores.size() >= 2:
		var objetivo = marcadores[indice_actual]
		if objetivo != null:
			var vel = velocidad_movimiento * (1.5 if en_rabia else 1.0)
			global_position = global_position.move_toward(
				objetivo.global_position, vel * delta)
			if global_position.distance_to(objetivo.global_position) < 5.0:
				indice_actual = (indice_actual + 1) % marcadores.size()

	tiempo_patron += delta
	var ciclo = fmod(tiempo_patron, 10.0)

	if not en_rabia:
		if ciclo < 4.0:
			velocidad_rotacion_actual = lerp(velocidad_rotacion_actual, velocidad_base_rotacion, 3 * delta)
		elif ciclo < 5.5:
			velocidad_rotacion_actual = lerp(velocidad_rotacion_actual, 0.0, 8 * delta)
		elif ciclo < 8.0:
			velocidad_rotacion_actual = lerp(velocidad_rotacion_actual, -velocidad_base_rotacion * 2.0, 4 * delta)
		else:
			velocidad_rotacion_actual = lerp(velocidad_rotacion_actual, 0.5, 3 * delta)
	else:
		var rapido = velocidad_base_rotacion * 2.5
		if ciclo < 3.0:
			velocidad_rotacion_actual = lerp(velocidad_rotacion_actual, rapido, 5 * delta)
		elif ciclo < 4.0:
			velocidad_rotacion_actual = lerp(velocidad_rotacion_actual, -rapido, 10 * delta)
		elif ciclo < 7.0:
			velocidad_rotacion_actual = lerp(velocidad_rotacion_actual, -rapido * 0.7, 4 * delta)
		else:
			velocidad_rotacion_actual = lerp(velocidad_rotacion_actual, 0.0, 6 * delta)

	rotation += velocidad_rotacion_actual * delta

	if shake_strength > 0:
		global_position += Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength))
		shake_strength = lerp(shake_strength, 0.0, 20.0 * delta)

func shake(intensidad := 8.0):
	shake_strength = intensidad

func recibir_dano(cantidad: int, es_critico := false):
	vida -= cantidad
	AudioManager.play_dano_enemigo()
	if vida <= 0:
		morir(es_critico)
	elif not en_rabia and vida <= vida_maxima * 0.5:
		en_rabia = true
		shake_strength = 20.0

func morir(es_critico := false):
	AudioManager.play_muerte_enemigo()
	GameManager.registrar_muerte_boss()

	if es_critico:
		crear_efecto_muerte_critica()
	else:
		crear_efecto_muerte()

	var dungeon_manager = get_tree().get_first_node_in_group("dungeon_manager")
	if dungeon_manager:
		dungeon_manager.enemigo_muerto()

	queue_free()

func congelar(duracion: float):
	var original = velocidad_movimiento
	velocidad_movimiento = 0
	modulate = Color(0.5, 0.6, 1, 1)
	await get_tree().create_timer(duracion).timeout
	if not is_inside_tree():
		return
	velocidad_movimiento = original
	modulate = Color(1, 1, 1, 1)

func crear_efecto_muerte():
	if escena_muerte == null:
		return
	var efecto = escena_muerte.instantiate()
	get_parent().add_child(efecto)
	efecto.global_position = global_position

func crear_efecto_muerte_critica():
	if escena_muerte_critica == null:
		return
	var efecto = escena_muerte_critica.instantiate()
	get_parent().add_child(efecto)
	efecto.global_position = global_position
