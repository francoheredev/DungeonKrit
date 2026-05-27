extends CharacterBody2D


@export var velocidad: float = 400.0

var tocando: bool = false #o tocas o no tocas
var inicio_toque: Vector2 = Vector2.ZERO
var direccion: Vector2 = Vector2.ZERO

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
	if tocando:
		velocity = direccion * velocidad
	else:
		velocity = Vector2.ZERO # si no tocamos el personaje no se mueve
		
	move_and_slide()
