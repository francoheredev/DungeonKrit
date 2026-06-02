extends Area2D

@export var velocidad_movimiento: float = 200.0
@export var marcadores: Array[Marker2D] = []

# --- CONFIGURACIÓN ESTILO KNIFE HIT ---
@export var velocidad_base_rotacion: float = 4.0  # Velocidad normal de giro

var velocidad_rotacion_actual: float = 0.0
var tiempo_patron: float = 0.0
var indice_actual: int = 0

func _process(delta):
	# se mueve entre los marcadores de mi array
	if marcadores.size() > 0:
		var objetivo = marcadores[indice_actual]
		if objetivo != null:
			global_position = global_position.move_toward(objetivo.global_position, velocidad_movimiento * delta)
			if global_position.distance_to(objetivo.global_position) < 5.0:
				indice_actual = (indice_actual + 1) % marcadores.size()

	# 2. ROTACIÓN DINÁMICA (Estilo Knife Hit)
	tiempo_patron += delta
	
	# Creamos un bucle infinito que se repite cada 8 segundos
	var ciclo = fmod(tiempo_patron, 8.0)
	
	# Definimos el comportamiento según el segundo del ciclo en el que estemos:
	if ciclo < 3.0:
		# Fase 1 (Segundos 0 a 3): Giro normal hacia la derecha
		# lerp() hace que el cambio de velocidad no sea brusco, dándole "peso" al enemigo
		velocidad_rotacion_actual = lerp(velocidad_rotacion_actual, velocidad_base_rotacion, 5 * delta)
		
	elif ciclo < 4.2:
		# Fase 2 (Segundos 3 a 4.2): ¡Freno de mano en seco! (Se detiene por completo)
		velocidad_rotacion_actual = lerp(velocidad_rotacion_actual, 0.0, 12 * delta)
		
	elif ciclo < 6.5:
		# Fase 3 (Segundos 4.2 a 6.5): ¡Sorpresa! Gira rápido hacia la IZQUIERDA (reversa)
		# El signo menos (-) cambia la dirección, y multiplicamos por 1.8 para que sea más rápido
		velocidad_rotacion_actual = lerp(velocidad_rotacion_actual, -velocidad_base_rotacion * 1.8, 6 * delta)
		
	else:
		# Fase 4 (Segundos 6.5 a 8): Se queda casi congelado amagando antes de reiniciar
		velocidad_rotacion_actual = lerp(velocidad_rotacion_actual, 0.3, 4 * delta)
		
	# Aplicamos la velocidad que calculamos al ángulo del enemigo
	rotation += velocidad_rotacion_actual * delta


func _on_area_entered(area: Area2D) -> void:
	print("area")
