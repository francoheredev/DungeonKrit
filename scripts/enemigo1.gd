extends Area2D
 
@export var velocidad_movimiento: float = 200.0
@export var marcadores: Array[Marker2D] = []
@export var velocidad_base_rotacion: float = 4.0
@export var vida_maxima: int = 5

var indice_actual: int = 0
var vida: int = 0
 
func _ready():
	vida = vida_maxima
 
func _process(delta):
	# Movimiento izquierda-derecha del enemigo
	if marcadores.size() > 0:
		var objetivo = marcadores[indice_actual]
		if objetivo != null:
			global_position = global_position.move_toward(objetivo.global_position, velocidad_movimiento * delta)
			if global_position.distance_to(objetivo.global_position) < 5.0:
				indice_actual = (indice_actual + 1) % marcadores.size()

	# Gira constantemente (you spin me around baby around)
	rotation += velocidad_base_rotacion * delta / 2
 
func recibir_daño(cantidad: int):
	vida -= cantidad
	print("Enemigo vida: ", vida)
	if vida <= 0:
		queue_free()
