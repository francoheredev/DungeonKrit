extends CharacterBody2D
 
@export var velocidad_apuntado: float = 90.0  # Con esto ajustamos la velocidad con la que rota el pj
@export var offset_disparo: Vector2 = Vector2(60, -120)  # De donde sale la bala
 
var tocando: bool = false
var vivo: bool = true
var angulo_mira: float = 0.0
var drag_x: float = 0.0
 
@onready var sprite = $AnimatedSprite2D
 
var proyectil_scene = preload("res://escenas/proyectil.tscn")
 
 
func _input(event):
	if not vivo: return
 
	if event is InputEventScreenTouch:
		tocando = event.pressed
		if not event.pressed:
			# Al soltar el dedo, dispara
			_disparar()
 
	elif event is InputEventScreenDrag and tocando:
		drag_x += event.relative.x
 
 
func _physics_process(_delta):
	if not vivo: return
 
	if drag_x != 0.0:
		var pantalla = get_viewport().get_visible_rect().size.x
		var movimiento = (drag_x / pantalla) * deg_to_rad(velocidad_apuntado)
		angulo_mira += movimiento  # Sin delta porque sino no se mueve nada
		angulo_mira = clamp(angulo_mira, -PI/2, PI/2)
		rotation = angulo_mira
		drag_x = 0.0
 
 
func _disparar():
	var proyectil = proyectil_scene.instantiate()
	# Lo agregamos al padre pa que no herede la rotación del jugador
	get_parent().add_child(proyectil)
	# Offset rotado según donde apunta el jugador
	var pos_disparo = global_position + offset_disparo.rotated(angulo_mira)
	proyectil.iniciar(pos_disparo, angulo_mira)
 
