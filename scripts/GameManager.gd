extends Node

var puntos := 0
var kills := 0
var krits := 0
var krits_totales := 0

func reset():
	puntos = 0
	kills = 0

func agregar_krit(cantidad := 1):
	krits += cantidad
	krits_totales += cantidad
