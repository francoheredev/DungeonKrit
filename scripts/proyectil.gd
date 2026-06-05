extends Area2D
 
@export var velocidad: float = 1200.0
 
var direccion: Vector2 = Vector2.ZERO
var clavado: bool = false
 
 
func iniciar(pos_global: Vector2, angulo: float):
	global_position = pos_global
	rotation = angulo
	direccion = Vector2.UP.rotated(angulo)
 
 
func _process(delta):
	if clavado: return
	position += direccion * velocidad * delta
 
	var pantalla = get_viewport().get_visible_rect()
	if not pantalla.has_point(global_position):
		queue_free()
 
 
func _on_area_entered(area: Area2D):
	if clavado: return
 
	# Chocó con otra flecha clavada: rebota (se destruye y no hace daño)
	if area.is_in_group("flechas_clavadas"):
		queue_free()
		return
 
	# Chocó con un enemigo: se clava
	if area.is_in_group("enemigos"):
		_clavarse_en(area)
		area.recibir_daño(1)
 
 
func _clavarse_en(enemigo: Area2D):
	clavado = true
 
	# Desconectamos del padre actual y lo volvemos hijo del enemigo
	var pos_global_guardada = global_position
	var rot_global_guardada = rotation
 
	get_parent().remove_child(self)
	enemigo.add_child(self)
 
	global_position = pos_global_guardada
	# Esto es pa que la flecha apunte al centro del enemigo y no quede mirando a cuenca tio me cago en
	var dir_al_centro = enemigo.global_position - pos_global_guardada
	var angulo_al_centro = dir_al_centro.angle() + PI / 2
	rotation = angulo_al_centro - enemigo.rotation
 
	# Ahora la flecha puede destruir otras
	global_position += direccion * 30.0  # Esto es para ajustar cuanto se entierra la bala
	add_to_group("flechas_clavadas")
