extends CharacterBody2D

@export var velocidad: float = 500
@export var velocidad_apuntado: float = 10.0
@export var escena_proyectil: PackedScene
@export var escena_muerte: PackedScene
@export var cooldown_disparo := 0.3
@export var distancia_arrastre := 40.0

var tocando: bool = false
var arrastrando: bool = false
var inicio_toque: Vector2 = Vector2.ZERO
var direccion: Vector2 = Vector2.ZERO
var vivo: bool = true
var puede_disparar: bool = true

@onready var radio_vision = $radio_vision
@onready var hitbox = $Hitbox


func _input(event):
	if not vivo:
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			tocando = true
			arrastrando = false
			inicio_toque = event.position
		else:
			if not arrastrando:
				disparar()

			tocando = false
			direccion = Vector2.ZERO

	elif event is InputEventScreenDrag and tocando:
		var distancia = event.position.distance_to(inicio_toque)

		if distancia > distancia_arrastre:
			arrastrando = true
			direccion = (event.position - inicio_toque).normalized()


func _physics_process(delta):
	if not vivo:
		return

	velocity = direccion * velocidad if tocando else Vector2.ZERO
	move_and_slide()

	_apuntar_al_enemigo_cercano(delta)
	_detectar_colision_enemigo()


func _apuntar_al_enemigo_cercano(delta):
	var areas = radio_vision.get_overlapping_areas()
	var objetivo = null
	var distancia_min = INF

	for area in areas:
		if area.is_in_group("enemigos"):
			var d = global_position.distance_to(area.global_position)

			if d < distancia_min:
				distancia_min = d
				objetivo = area

	# DEBUG IMPORTANTE (solo si falla en sala 3)
	if objetivo == null:
		print("DEBUG: sin objetivo en radio | overlaps=", areas.size())

	if objetivo:
		var dir = objetivo.global_position - global_position
		var angulo = dir.angle() + PI / 2
		rotation = lerp_angle(rotation, angulo, velocidad_apuntado * delta)


func disparar():
	if not puede_disparar:
		return

	# 🔥 FIX CLAVE: no dependemos de enemigo_actual ni estado cacheado
	var hay_enemigo = false

	for area in radio_vision.get_overlapping_areas():
		if area.is_in_group("enemigos"):
			hay_enemigo = true
			break

	# DEBUG para tu bug de sala 3
	print("DISPARO INTENTO | enemigos en rango:", radio_vision.get_overlapping_areas().size())

	if not hay_enemigo:
		print("DISPARO CANCELADO (sin enemigo detectado)")
		return

	puede_disparar = false

	var flecha = escena_proyectil.instantiate()
	get_parent().add_child(flecha)

	flecha.global_position = global_position + Vector2(55, -100).rotated(global_rotation)
	flecha.global_rotation = global_rotation
	flecha.direccion = Vector2.UP.rotated(global_rotation)

	await get_tree().create_timer(cooldown_disparo).timeout

	if vivo:
		puede_disparar = true


func _detectar_colision_enemigo():
	for area in hitbox.get_overlapping_areas():
		if area.is_in_group("enemigos"):
			die()
			return


func die():
	if not vivo:
		return

	vivo = false
	tocando = false
	puede_disparar = false

	if escena_muerte:
		var efecto = escena_muerte.instantiate()
		get_parent().add_child(efecto)
		efecto.global_position = global_position

		if efecto is GPUParticles2D:
			efecto.emitting = true

	visible = false

	print("¡El jugador ha muerto!")

	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()
