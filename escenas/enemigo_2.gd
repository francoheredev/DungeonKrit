extends Area2D

@export var velocidad_movimiento: float = 200.0
@export var marcadores: Array[Marker2D] = []
@export var velocidad_base_rotacion: float = 4.0
@export var escena_critico: PackedScene
@export var cantidad_criticos := 2
@export var radio_criticos := 105
@export var escena_muerte: PackedScene
@export var escena_muerte_critica: PackedScene
# VIDA
@export var vida_maxima: int = 40

var vida: int
var shake_strength := 0.0
var velocidad_rotacion_actual: float = 0.0
var tiempo_patron: float = 0.0
var indice_actual: int = 0

func _ready():
	vida = vida_maxima
	generar_criticos()

func generar_criticos():
	for i in cantidad_criticos:
		var critico = escena_critico.instantiate()

		add_child(critico)

		var angulo = randf_range(0, TAU)

		critico.position = Vector2.RIGHT.rotated(angulo) * radio_criticos
func _process(delta):
	# Movimiento entre marcadores
	if marcadores.size() > 0:
		var objetivo = marcadores[indice_actual]

		if objetivo != null:
			global_position = global_position.move_toward(
				objetivo.global_position,
				velocidad_movimiento * delta
			)

			if global_position.distance_to(objetivo.global_position) < 5.0:
				indice_actual = (indice_actual + 1) % marcadores.size()

	# Rotación dinámica estilo Knife Hit
	tiempo_patron += delta
	var ciclo = fmod(tiempo_patron, 8.0)

	if ciclo < 3.0:
		velocidad_rotacion_actual = lerp(
			velocidad_rotacion_actual,
			velocidad_base_rotacion,
			5 * delta
		)
	elif ciclo < 4.2:
		velocidad_rotacion_actual = lerp(
			velocidad_rotacion_actual,
			0.0,
			12 * delta
		)
	elif ciclo < 6.5:
		velocidad_rotacion_actual = lerp(
			velocidad_rotacion_actual,
			-velocidad_base_rotacion * 1.8,
			6 * delta
		)
	else:
		velocidad_rotacion_actual = lerp(
			velocidad_rotacion_actual,
			0.3,
			4 * delta
		)

	rotation += velocidad_rotacion_actual * delta
# Shake visual
	if shake_strength > 0:
		global_position += Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)

		shake_strength = lerp(shake_strength, 0.0, 20.0 * delta)
		
func shake(intensidad := 8.0):
	shake_strength = intensidad

func recibir_dano(cantidad: int, es_critico := false):
	vida -= cantidad

	if vida <= 0:
		morir(es_critico)


func morir(es_critico := false):
	GameManager.kills += 1
	GameManager.puntos += 100

	if es_critico:
		crear_efecto_muerte_critica()
	else:
		crear_efecto_muerte()

	queue_free()
	

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
