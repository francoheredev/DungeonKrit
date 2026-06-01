extends CharacterBody2D

@export var velocidad: float = 400.0
@export var velocidad_apuntado: float = 10.0 # que tan rápido apunta

var tocando: bool = false # o tocas o no tocas
var inicio_toque: Vector2 = Vector2.ZERO
var direccion: Vector2 = Vector2.ZERO
@onready var radio_vision = $radio_vision
@onready var laser = $Line2D 
func _input(event):
	# esto detecta el primer toque y soltar
	if event is InputEventScreenTouch:
		if event.pressed: # dedo en la pantalla
			tocando = true
			inicio_toque = event.position
		else: # no tocamos
			tocando = false
			direccion = Vector2.ZERO
			
	# arrastrando el dedo
	elif event is InputEventScreenDrag and tocando:
		var toque_actual = event.position
		# dirección
		direccion = (toque_actual - inicio_toque).normalized()


func _physics_process(delta):
	# 1. CONTROL DE MOVIMIENTO 
	if tocando:
		velocity = direccion * velocidad
	else:
		velocity = Vector2.ZERO # si no tocamos, el personaje no se mueve
		
	move_and_slide()
	
	# 2. SISTEMA DE VISIÓN Y APUNTADO
	apuntar_al_enemigo_cercano(delta)


func apuntar_al_enemigo_cercano(delta):
	# busca SOLO nodos de tipo Area2D
	var areas_dentro = radio_vision.get_overlapping_areas()
	
	var enemigo_objetivo = null #no hay enemigo objetivo
	var distancia_minima = INF 
	if areas_dentro.size() > 0:
		print("¡Círculo tocando algo! Total de áreas: ", areas_dentro.size())
	for area in areas_dentro:
		# Verificamos si el Area2D pertenece al grupo de los enemigos
		if area.is_in_group("enemigos"):
			var distancia_actual = global_position.distance_to(area.global_position)
			
			if distancia_actual < distancia_minima:
				distancia_minima = distancia_actual
				enemigo_objetivo = area
				
	# Si encontramos el área enemiga más cercana, apuntamos y encendemos el láser
	if enemigo_objetivo != null:
		var direccion_hacia_enemigo = enemigo_objetivo.global_position - global_position
		var angulo_objetivo = direccion_hacia_enemigo.angle() + PI/2
		rotation = lerp_angle(rotation, angulo_objetivo, velocidad_apuntado * delta)
		
		var posicion_local_enemigo = to_local(enemigo_objetivo.global_position)
		laser.points = [Vector2.ZERO, posicion_local_enemigo]
		laser.visible = true
	else:
		# Si no hay ningún Area2D del grupo "enemigos", apagamos el indicador
		laser.visible = false
