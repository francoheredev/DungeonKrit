extends CharacterBody2D

@export var velocidad: float = 500
@export var velocidad_apuntado: float = 10.0
@export var escena_proyectil: PackedScene

var tocando: bool = false
var arrastrando: bool = false
var inicio_toque: Vector2 = Vector2.ZERO
var direccion: Vector2 = Vector2.ZERO
var vivo: bool = true
var puede_disparar: bool = true

@onready var radio_vision = $radio_vision
@onready var hitbox = $Hitbox
@onready var laser = $Line2D

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

		if distancia > 20:
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

	if objetivo != null:
		var dir = objetivo.global_position - global_position
		var angulo = dir.angle() + PI / 2

		rotation = lerp_angle(rotation, angulo, velocidad_apuntado * delta)

		laser.points = [
			Vector2.ZERO,
			to_local(objetivo.global_position)
		]

		laser.visible = false
	else:
		laser.visible = false

func disparar():
	if not puede_disparar:
		return

	var flecha = escena_proyectil.instantiate()

	get_parent().add_child(flecha)

	flecha.global_position = global_position + Vector2(55, -100).rotated(global_rotation)
	flecha.global_rotation = global_rotation
	flecha.direccion = Vector2.UP.rotated(global_rotation)

	puede_disparar = false

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

	laser.visible = false

	print("¡El jugador ha muerto!")

	await get_tree().create_timer(1.0).timeout

	get_tree().reload_current_scene()
