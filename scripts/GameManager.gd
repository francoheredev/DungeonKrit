extends Node

var puntos := 0
var kills := 0
var krits := 0
var krits_totales := 0
var selected_character := 0

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
]

func reset():
	puntos = 0
	kills = 0

func agregar_krit(cantidad := 1):
	krits += cantidad
	krits_totales += cantidad
