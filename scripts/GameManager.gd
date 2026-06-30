extends Node

var puntos := 0
var kills := 0
var kills_totales := 0
var krits := 0
var krits_run := 0
var krits_totales := 0
var selected_character := 0
var runas := 0
var personajes_desbloqueados := [true, false, false, false]
var contador_resurrecciones := 0
var revive_gratis_disponible := true

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
		name = "Asesino",
		proyectil = preload("res://escenas/proyectil2.tscn"),
		muerte = preload("res://escenas/muerte_jugador.tscn"),
		velocidad = 800,
		velocidad_apuntado = 20.0,
		cooldown_disparo = 0.12,
		dano = 4,
		velocidad_proyectil = 1500.0,
		distancia_maxima_proyectil = 1600.0,
		offset_proyectil = Vector2(55, -100),
	},
	{
		name = "Mago",
		proyectil = preload("res://escenas/proyectil3.tscn"),
		muerte = preload("res://escenas/muerte_jugador.tscn"),
		velocidad = 600,
		velocidad_apuntado = 12.0,
		cooldown_disparo = 0.35,
		dano = 14,
		velocidad_proyectil = 1100.0,
		distancia_maxima_proyectil = 1500.0,
		offset_proyectil = Vector2(60, -100),
	},
	{
		name = "Ronin",
		proyectil = preload("res://escenas/proyectil4.tscn"),
		muerte = preload("res://escenas/muerte_jugador.tscn"),
		velocidad = 500,
		velocidad_apuntado = 22.0,
		cooldown_disparo = 0.5,
		dano = 18,
		velocidad_proyectil = 1800.0,
		distancia_maxima_proyectil = 2500.0,
		offset_proyectil = Vector2(60, -100),
	},
]

const PRECIO_PERSONAJES = [0, 50, 0, 100]
const PRECIO_RUNAS_PERSONAJES = [0, 0, 100, 0]

const PAQUETES_RUNAS = [
	{runas = 100, precio = "$1"},
	{runas = 500, precio = "$5"},
	{runas = 1000, precio = "$10"},
]

var logros_desbloqueados := {}
var progreso_logros := {}
var logros_reclamados := {}

const LOGROS = [
	{id = "first_blood", name = "Primera Sangre", desc = "Mata a tu primer enemigo"},
	{id = "25_kills", name = "Novato", desc = "Mata 25 enemigos", max = 25, recompensa = {runas = 25}},
	{id = "centurion", name = "Centurión", desc = "Mata 100 enemigos", max = 100, recompensa = {runas = 50}},
	{id = "crit_coleccionista", name = "Crítico", desc = "Consigue 10 krits en una run", max = 10, recompensa = {runas = 10}},
	{id = "rico", name = "Rico", desc = "Acumula 1000 krits totales", max = 1000, recompensa = {runas = 100}},
	{id = "millonario", name = "Krit Millonario", desc = "Acumula 5000 krits totales", max = 5000, recompensa = {runas = 200}},
	{id = "superviviente", name = "Superviviente", desc = "Llega al ciclo 5", max = 5, recompensa = {runas = 30}},
	{id = "amo_mazmorra", name = "Amo de la Mazmorra", desc = "Llega al ciclo 10", max = 10, recompensa = {runas = 75}},
	{id = "cazador_jefes", name = "Cazador de Jefes", desc = "Mata a tu primer jefe", recompensa = {runas = 20}},
	{id = "coleccionista", name = "Coleccionista", desc = "Desbloquea todos los personajes", recompensa = {runas = 150}},
	{id = "regreso", name = "Regreso", desc = "Revive una vez", recompensa = {runas = 5}},
]

func desbloquear_logro(id: String) -> bool:
	if logros_desbloqueados.has(id) and logros_desbloqueados[id]:
		return false
	logros_desbloqueados[id] = true
	print("Logro desbloqueado: ", id)
	guardar_datos()
	return true

func reclamar_recompensa(id: String) -> bool:
	if not logros_desbloqueados.has(id) or not logros_desbloqueados[id]:
		return false
	if logros_reclamados.has(id) and logros_reclamados[id]:
		return false
	for l in LOGROS:
		if l.id == id and l.has("recompensa"):
			var r = l.recompensa
			if r.has("runas"):
				runas = mini(runas + r.runas, 9999)
			logros_reclamados[id] = true
			print("Recompensa reclamada: ", id, " ", r)
			guardar_datos()
			return true
	return false

func verificar_logro(id: String) -> bool:
	for l in LOGROS:
		if l.id == id:
			return desbloquear_logro(id)
	return false

func _ready():
	cargar_datos()

func reset():
	puntos = 0
	kills = 0
	krits_run = 0
	contador_resurrecciones = 0
	revive_gratis_disponible = true

func registrar_muerte_enemigo():
	kills += 1
	kills_totales += 1
	puntos += 100
	progreso_logros["25_kills"] = kills_totales
	progreso_logros["centurion"] = kills_totales
	if kills_totales >= 1:
		verificar_logro("first_blood")
	if kills_totales >= 25:
		verificar_logro("25_kills")
	if kills_totales >= 100:
		verificar_logro("centurion")

func registrar_muerte_boss():
	kills += 1
	kills_totales += 1
	puntos += 500
	progreso_logros["25_kills"] = kills_totales
	progreso_logros["centurion"] = kills_totales
	if kills_totales >= 1:
		verificar_logro("first_blood")
	if kills_totales >= 25:
		verificar_logro("25_kills")
	if kills_totales >= 100:
		verificar_logro("centurion")
	verificar_logro("cazador_jefes")

func agregar_krit(cantidad := 1):
	krits += cantidad
	krits_run += cantidad
	krits_totales = mini(krits_totales + cantidad, 9999)
	progreso_logros["crit_coleccionista"] = krits_run
	progreso_logros["rico"] = krits_totales
	progreso_logros["millonario"] = krits_totales
	if krits_run >= 10:
		verificar_logro("crit_coleccionista")
	if krits_totales >= 1000:
		verificar_logro("rico")
	if krits_totales >= 5000:
		verificar_logro("millonario")

func comprar_personaje(indice: int) -> bool:
	if indice <= 0 or indice >= personajes_desbloqueados.size():
		return false
	if personajes_desbloqueados[indice]:
		return false

	var precio_krits = PRECIO_PERSONAJES[indice]
	var precio_runas = PRECIO_RUNAS_PERSONAJES[indice]

	if precio_krits > 0:
		if krits_totales < precio_krits:
			return false
		krits_totales -= precio_krits
	elif precio_runas > 0:
		if runas < precio_runas:
			return false
		runas -= precio_runas

	personajes_desbloqueados[indice] = true
	guardar_datos()
	_verificar_coleccionista()
	return true

func _verificar_coleccionista():
	for p in personajes_desbloqueados:
		if not p:
			return
	verificar_logro("coleccionista")

func actualizar_ciclo(ciclo: int):
	progreso_logros["superviviente"] = ciclo
	progreso_logros["amo_mazmorra"] = ciclo

func comprar_runas(paquete_idx: int) -> bool:
	if paquete_idx < 0 or paquete_idx >= PAQUETES_RUNAS.size():
		return false
	var paquete = PAQUETES_RUNAS[paquete_idx]
	runas = mini(runas + paquete.runas, 9999)
	guardar_datos()
	return true

const RUTA_DATOS := "user://shop_data.cfg"

func guardar_datos():
	var config = ConfigFile.new()
	config.set_value("shop", "runas", runas)
	config.set_value("shop", "krits_totales", krits_totales)
	config.set_value("shop", "personajes_desbloqueados", personajes_desbloqueados)
	config.set_value("logros", "desbloqueados", logros_desbloqueados)
	config.set_value("logros", "progreso", progreso_logros)
	config.set_value("logros", "reclamados", logros_reclamados)
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
	if config.has_section_key("logros", "desbloqueados"):
		logros_desbloqueados = config.get_value("logros", "desbloqueados")
	if config.has_section_key("logros", "progreso"):
		progreso_logros = config.get_value("logros", "progreso")
	if config.has_section_key("logros", "reclamados"):
		logros_reclamados = config.get_value("logros", "reclamados")
