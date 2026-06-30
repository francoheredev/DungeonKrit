extends CharacterBody2D

@export var velocidad: float = 700
@export var velocidad_apuntado: float = 15.0
@export var escena_proyectil: PackedScene
@export var escena_muerte: PackedScene
@export var cooldown_disparo := 0.3
@export var distancia_arrastre := 40.0
@export var opciones_sprite_frames: Array[SpriteFrames]

var tocando: bool = false
var arrastrando: bool = false
var inicio_toque: Vector2 = Vector2.ZERO
var direccion: Vector2 = Vector2.ZERO
var vivo: bool = true
var puede_disparar: bool = true
var invulnerable := false
var posicion_inicial: Vector2

@onready var radio_vision = $radio_vision
@onready var hitbox = $Hitbox


func _ready():
	posicion_inicial = global_position
	var idx = GameManager.selected_character
	var data = GameManager.CHARACTER_DATA[idx]

	velocidad = data.velocidad
	velocidad_apuntado = data.velocidad_apuntado
	cooldown_disparo = data.cooldown_disparo
	escena_proyectil = data.proyectil
	escena_muerte = data.muerte

	if idx < opciones_sprite_frames.size():
		$AnimatedSprite2D2.sprite_frames = opciones_sprite_frames[idx]


func _input(event):
	if not vivo:
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			tocando = true
			arrastrando = false
			inicio_toque = event.position
		else:
			disparar()

			tocando = false
			arrastrando = false
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
	#if objetivo == null:
		#print("DEBUG: sin objetivo en radio | overlaps=", areas.size())

	if objetivo:
		var dir = objetivo.global_position - global_position
		var angulo = dir.angle() + PI / 2
		rotation = lerp_angle(rotation, angulo, velocidad_apuntado * delta)


func disparar():
	if not puede_disparar:
		return

	puede_disparar = false

	var data = GameManager.CHARACTER_DATA[GameManager.selected_character]
	var offset = data.offset_proyectil

	var flecha = escena_proyectil.instantiate()
	get_parent().add_child(flecha)

	flecha.global_position = global_position + offset.rotated(global_rotation)
	flecha.global_rotation = global_rotation
	flecha.direccion = Vector2.UP.rotated(global_rotation)
	flecha.dano = data.dano
	flecha.velocidad = data.velocidad_proyectil
	flecha.distancia_maxima = data.distancia_maxima_proyectil

	match GameManager.selected_character:
		0: AudioManager.play_arco()
		1: AudioManager.play_kunai()
		2: AudioManager.play_hielo()
		3: AudioManager.play_cuchi()

	await get_tree().create_timer(cooldown_disparo).timeout

	if vivo:
		puede_disparar = true


func _detectar_colision_enemigo():
	if invulnerable:
		return
	for area in hitbox.get_overlapping_areas():
		if area.is_in_group("enemigos"):
			die()
			return


func die():
	if not vivo:
		return

	vivo = false
	AudioManager.play_muerte_pj()
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

	var overlay = get_node("../CanvasLayer/ReviveOverlay")
	if overlay and overlay.has_method("mostrar"):
		overlay.mostrar()

func revivir():
	vivo = true
	visible = true
	puede_disparar = true
	invulnerable = true
	global_position = posicion_inicial
	await get_tree().create_timer(1.5).timeout
	invulnerable = false
