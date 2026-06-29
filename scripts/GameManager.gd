extends Node

var puntos := 0
var kills := 0
var krits := 0
var krits_totales := 0
var selected_character := 0
var runas := 0
var personajes_desbloqueados := [true, false, false, false]

const CHARACTER_DATA = [
	{
		name = "Arquero",
		proyectil = preload("res://escenas/proyectil.tscn"),
		muerte = preload("res://escenas/muerte_jugador.tscn"),
		velocidad = 700,
		velocidad_apuntado = 15.0,
		cooldown_disparo = 0.3,
		dano = 10,
		velocidad_proyectil = 1300.0,
		distancia_maxima_proyectil = 2000.0,
		offset_proyectil = Vector2(55, -100),
	},
	{
		name = "Mago",
		proyectil = preload("res://escenas/proyectil2.tscn"),
		muerte = preload("res://escenas/muerte_jugador.tscn"),
		velocidad = 600,
		velocidad_apuntado = 18.0,
		cooldown_disparo = 0.15,
		dano = 5,
		velocidad_proyectil = 1400.0,
		distancia_maxima_proyectil = 2000.0,
		offset_proyectil = Vector2(55, -100),
	},
	{
		name = "Luchador",
		proyectil = preload("res://escenas/proyectil3.tscn"),
		muerte = preload("res://escenas/muerte_jugador.tscn"),
		velocidad = 750,
		velocidad_apuntado = 20.0,
		cooldown_disparo = 0.2,
		dano = 8,
		velocidad_proyectil = 1500.0,
		distancia_maxima_proyectil = 1600.0,
		offset_proyectil = Vector2(60, -100),
	},
	{
		name = "Artillero",
		proyectil = preload("res://escenas/proyectil4.tscn"),
		muerte = preload("res://escenas/muerte_jugador.tscn"),
		velocidad = 550,
		velocidad_apuntado = 12.0,
		cooldown_disparo = 0.35,
		dano = 15,
		velocidad_proyectil = 1600.0,
		distancia_maxima_proyectil = 2200.0,
		offset_proyectil = Vector2(60, -100),
	},
]

const PRECIO_PERSONAJES = [0, 50, 100, 200]

const PAQUETES_RUNAS = [
	{runas = 100, precio = "$1"},
	{runas = 500, precio = "$5"},
	{runas = 1000, precio = "$10"},
]

func _ready():
	cargar_datos()

func reset():
	puntos = 0
	kills = 0

func agregar_krit(cantidad := 1):
	krits += cantidad
	krits_totales += cantidad

func comprar_personaje(indice: int) -> bool:
	if indice <= 0 or indice >= personajes_desbloqueados.size():
		return false
	if personajes_desbloqueados[indice]:
		return false
	var precio = PRECIO_PERSONAJES[indice]
	if krits_totales < precio:
		return false
	krits_totales -= precio
	personajes_desbloqueados[indice] = true
	guardar_datos()
	return true

func comprar_runas(paquete_idx: int) -> bool:
	if paquete_idx < 0 or paquete_idx >= PAQUETES_RUNAS.size():
		return false
	var paquete = PAQUETES_RUNAS[paquete_idx]
	runas += paquete.runas
	guardar_datos()
	return true

const RUTA_DATOS := "user://shop_data.cfg"

func guardar_datos():
	var config = ConfigFile.new()
	config.set_value("shop", "runas", runas)
	config.set_value("shop", "krits_totales", krits_totales)
	config.set_value("shop", "personajes_desbloqueados", personajes_desbloqueados)
	config.save(RUTA_DATOS)

func cargar_datos():
	var config = ConfigFile.new()
	if config.load(RUTA_DATOS) != OK:
		return
	if config.has_section_key("shop", "runas"):
		runas = config.get_value("shop", "runas")
	if config.has_section_key("shop", "krits_totales"):
		krits_totales = config.get_value("shop", "krits_totales")
	if config.has_section_key("shop", "personajes_desbloqueados"):
		personajes_desbloqueados = config.get_value("shop", "personajes_desbloqueados")
