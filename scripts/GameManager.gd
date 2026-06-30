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
var puntos_totales := 0
var kills_run_max := 0
var puntos_run_max := 0
var tiempo_total := 0.0
var tiempo_run := 0.0
var tiempo_run_max := 0.0
var muertes_totales := 0
var krits_boss_totales := 0
var racha_hits := 0
var racha_hits_max := 0
var racha_krits := 0
var racha_krits_max := 0
var congelados_totales := 0
var ejecuciones_totales := 0
var kills_por_personaje := [0, 0, 0, 0]
var krits_por_personaje := [0, 0, 0, 0]

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
		pasiva = {id = "doble_puntos", multiplicador = 2.0},
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
		pasiva = {id = "critico_mortal", multiplicador = 2.0},
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
		pasiva = {id = "congelar", prob = 0.25, duracion = 1.5, revive_gratis = true},
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
		pasiva = {id = "ejecutar", prob = 0.08},
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
	# Progresión por ciclos
	{id = "superviviente", name = "Superviviente", desc = "Llega al ciclo 5", max = 5, recompensa = {runas = 30}},
	{id = "amo_mazmorra", name = "Amo de la Mazmorra", desc = "Llega al ciclo 10", max = 10, recompensa = {runas = 75}},
	{id = "cazador_jefes", name = "Cazador de Jefes", desc = "Mata a tu primer jefe", recompensa = {runas = 20}},

	# 1. Puntuación total
	{id = "puntos_total_b", name = "🥉 Aventurero Promesa", desc = "Alcanzá 25.000 puntos totales", max = 25000, recompensa = {runas = 25}},
	{id = "puntos_total_s", name = "🥈 Leyenda de la Mazmorra", desc = "Alcanzá 250.000 puntos totales", max = 250000, recompensa = {runas = 50}},
	{id = "puntos_total_g", name = "🥇 El Puntaje es Mío", desc = "Alcanzá 1.000.000 de puntos totales", max = 1000000, recompensa = {runas = 100}},

	# 2. Puntuación en una run
	{id = "puntos_run_b", name = "🥉 Buen Comienzo", desc = "Conseguí 10.000 puntos en una partida", max = 10000, recompensa = {runas = 25}},
	{id = "puntos_run_s", name = "🥈 Imparable", desc = "Conseguí 50.000 puntos en una partida", max = 50000, recompensa = {runas = 50}},
	{id = "puntos_run_g", name = "🥇 Run Perfecta", desc = "Conseguí 100.000 puntos en una partida", max = 100000, recompensa = {runas = 100}},

	# 3. Tiempo jugado total
	{id = "tiempo_total_b", name = "🥉 Recién Llegado", desc = "Jugá 1 hora", max = 3600, recompensa = {runas = 25}},
	{id = "tiempo_total_s", name = "🥈 Habitante de la Dungeon", desc = "Jugá 10 horas", max = 36000, recompensa = {runas = 50}},
	{id = "tiempo_total_g", name = "🥇 Sin Ver la Luz del Sol", desc = "Jugá 50 horas", max = 180000, recompensa = {runas = 100}},

	# 4. Tiempo en una run
	{id = "tiempo_run_b", name = "🥉 Resistencia", desc = "Sobreviví 10 minutos", max = 600, recompensa = {runas = 25}},
	{id = "tiempo_run_s", name = "🥈 Inquebrantable", desc = "Sobreviví 20 minutos", max = 1200, recompensa = {runas = 50}},
	{id = "tiempo_run_g", name = "🥇 ¿Todavía Seguís?", desc = "Sobreviví 40 minutos", max = 2400, recompensa = {runas = 100}},

	# 5. Kills totales
	{id = "kills_total_b", name = "🥉 Exterminador Novato", desc = "Eliminá 500 enemigos", max = 500, recompensa = {runas = 25}},
	{id = "kills_total_s", name = "🥈 Cazador Profesional", desc = "Eliminá 5.000 enemigos", max = 5000, recompensa = {runas = 50}},
	{id = "kills_total_g", name = "🥇 Plaga para los Monstruos", desc = "Eliminá 25.000 enemigos", max = 25000, recompensa = {runas = 100}},

	# 6. Kills en una run
	{id = "kills_run_b", name = "🥉 Barrido", desc = "Eliminá 100 enemigos", max = 100, recompensa = {runas = 25}},
	{id = "kills_run_s", name = "🥈 Masacre", desc = "Eliminá 300 enemigos", max = 300, recompensa = {runas = 50}},
	{id = "kills_run_g", name = "🥇 Genocidio Monstruoso", desc = "Eliminá 700 enemigos", max = 700, recompensa = {runas = 100}},

	# 9. Krits totales
	{id = "krits_total_b", name = "🥉 Buen Ojo", desc = "Acertá 100 Krits", max = 100, recompensa = {runas = 25}},
	{id = "krits_total_s", name = "🥈 Francotirador", desc = "Acertá 1.000 Krits", max = 1000, recompensa = {runas = 50}},
	{id = "krits_total_g", name = "🥇 Cirujano", desc = "Acertá 10.000 Krits", max = 10000, recompensa = {runas = 100}},

	# 10. Krits a jefes
	{id = "krits_boss_b", name = "🥉 Punto Débil", desc = "Acertá 25 Krits a jefes", max = 25, recompensa = {runas = 25}},
	{id = "krits_boss_s", name = "🥈 Azote de los Jefes", desc = "Acertá 250 Krits a jefes", max = 250, recompensa = {runas = 50}},
	{id = "krits_boss_g", name = "🥇 Verdugo de Titanes", desc = "Acertá 1.000 Krits a jefes", max = 1000, recompensa = {runas = 100}},

	# 11. Desbloquear personajes
	{id = "desbloquear_b", name = "🥉 Primer Recluta", desc = "Desbloqueá 2 personajes", max = 2, recompensa = {runas = 25}},
	{id = "desbloquear_s", name = "🥈 Coleccionista", desc = "Desbloqueá 3 personajes", max = 3, recompensa = {runas = 50}},
	{id = "coleccionista", name = "🥇 Todos al Equipo", desc = "Desbloqueá todos los personajes", recompensa = {runas = 100}},

	# 12. Muertes
	{id = "muertes_b", name = "🥉 Eso Dolió", desc = "Morí 10 veces", max = 10, recompensa = {runas = 25}},
	{id = "muertes_s", name = "🥈 No Aprendo Más", desc = "Morí 100 veces", max = 100, recompensa = {runas = 50}},
	{id = "muertes_g", name = "🥇 Profesional del Respawn", desc = "Morí 500 veces", max = 500, recompensa = {runas = 100}},

	# 13. Racha de hits sin fallar
	{id = "racha_hits_b", name = "🥉 Sin Fallar", desc = "Conectá 25 golpes seguidos", max = 25, recompensa = {runas = 25}},
	{id = "racha_hits_s", name = "🥈 Precisión Absoluta", desc = "Conectá 75 golpes seguidos", max = 75, recompensa = {runas = 50}},
	{id = "racha_hits_g", name = "🥇 Máquina de Guerra", desc = "Conectá 150 golpes seguidos", max = 150, recompensa = {runas = 100}},

	# 14. Racha de krits sin fallar
	{id = "racha_krits_b", name = "🥉 Ojo Clínico", desc = "Conectá 10 Krits seguidos", max = 10, recompensa = {runas = 25}},
	{id = "racha_krits_s", name = "🥈 Precisión Quirúrgica", desc = "Conectá 25 Krits seguidos", max = 25, recompensa = {runas = 50}},
	{id = "racha_krits_g", name = "🥇 Krit Master", desc = "Conectá 50 Krits seguidos", max = 50, recompensa = {runas = 100}},

	# Personaje: Arquero
	{id = "arquero_experto", name = "🌳 Arquero del Bosque", desc = "Eliminá 1.000 enemigos con el Arquero", max = 1000, recompensa = {runas = 75}},

	# Personaje: Asesino
	{id = "asesino_mortal", name = "🗡️ Sombra Letal", desc = "Conectá 100 críticos con el Asesino", max = 100, recompensa = {runas = 75}},

	# Personaje: Mago
	{id = "mago_invierno", name = "❄️ Invierno Eterno", desc = "Congelá 200 enemigos con el Mago", max = 200, recompensa = {runas = 75}},

	# Personaje: Ronin
	{id = "ronin_ejecutor", name = "⚔️ Golpe de Gracia", desc = "Ejecutá 50 enemigos con el Ronin", max = 50, recompensa = {runas = 75}},

	# Secreto
	{id = "krit_final", name = "🏆 ¿Krit? ¡KRIT!", desc = "Asestá un crítico al último punto de vida de un jefe", recompensa = {runas = 100}},
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
	tiempo_run = 0.0
	racha_hits = 0
	racha_krits = 0

func registrar_muerte_enemigo():
	kills += 1
	kills_totales += 1
	puntos += 100
	kills_por_personaje[selected_character] += 1

	progreso_logros["kills_total_b"] = kills_totales
	progreso_logros["kills_total_s"] = kills_totales
	progreso_logros["kills_total_g"] = kills_totales
	progreso_logros["kills_run_b"] = max(kills, kills_run_max)
	progreso_logros["kills_run_s"] = max(kills, kills_run_max)
	progreso_logros["kills_run_g"] = max(kills, kills_run_max)
	progreso_logros["arquero_experto"] = kills_por_personaje[0]
	progreso_logros["asesino_mortal"] = krits_por_personaje[1]
	progreso_logros["mago_invierno"] = congelados_totales
	progreso_logros["ronin_ejecutor"] = ejecuciones_totales
	if kills_totales >= 500:
		verificar_logro("kills_total_b")
	if kills_totales >= 5000:
		verificar_logro("kills_total_s")
	if kills_totales >= 25000:
		verificar_logro("kills_total_g")
	if kills >= 100:
		verificar_logro("kills_run_b")
	if kills >= 300:
		verificar_logro("kills_run_s")
	if kills >= 700:
		verificar_logro("kills_run_g")
	var pj = kills_por_personaje[0]
	if pj >= 1000:
		verificar_logro("arquero_experto")
	if kills > kills_run_max:
		kills_run_max = kills
	guardar_datos()

func registrar_muerte_boss():
	kills += 1
	kills_totales += 1
	puntos += 500
	kills_por_personaje[selected_character] += 1

	progreso_logros["kills_total_b"] = kills_totales
	progreso_logros["kills_total_s"] = kills_totales
	progreso_logros["kills_total_g"] = kills_totales
	progreso_logros["kills_run_b"] = max(kills, kills_run_max)
	progreso_logros["kills_run_s"] = max(kills, kills_run_max)
	progreso_logros["kills_run_g"] = max(kills, kills_run_max)
	progreso_logros["arquero_experto"] = kills_por_personaje[0]
	progreso_logros["asesino_mortal"] = krits_por_personaje[1]
	progreso_logros["mago_invierno"] = congelados_totales
	progreso_logros["ronin_ejecutor"] = ejecuciones_totales
	if kills_totales >= 500:
		verificar_logro("kills_total_b")
	if kills_totales >= 5000:
		verificar_logro("kills_total_s")
	if kills_totales >= 25000:
		verificar_logro("kills_total_g")
	if kills >= 100:
		verificar_logro("kills_run_b")
	if kills >= 300:
		verificar_logro("kills_run_s")
	if kills >= 700:
		verificar_logro("kills_run_g")
	var pj = kills_por_personaje[0]
	if pj >= 1000:
		verificar_logro("arquero_experto")
	if kills > kills_run_max:
		kills_run_max = kills
	verificar_logro("cazador_jefes")
	guardar_datos()

func agregar_krit(cantidad := 1):
	krits += cantidad
	krits_run += cantidad
	krits_totales = mini(krits_totales + cantidad, 99999)
	krits_por_personaje[selected_character] += cantidad
	progreso_logros["krits_total_b"] = krits_totales
	progreso_logros["krits_total_s"] = krits_totales
	progreso_logros["krits_total_g"] = krits_totales
	progreso_logros["asesino_mortal"] = krits_por_personaje[1]
	if krits_totales >= 100:
		verificar_logro("krits_total_b")
	if krits_totales >= 1000:
		verificar_logro("krits_total_s")
	if krits_totales >= 10000:
		verificar_logro("krits_total_g")
	if krits_por_personaje[1] >= 100:
		verificar_logro("asesino_mortal")

func agregar_krit_boss(cantidad := 1):
	agregar_krit(cantidad)
	krits_boss_totales += cantidad
	progreso_logros["krits_boss_b"] = krits_boss_totales
	progreso_logros["krits_boss_s"] = krits_boss_totales
	progreso_logros["krits_boss_g"] = krits_boss_totales
	if krits_boss_totales >= 25:
		verificar_logro("krits_boss_b")
	if krits_boss_totales >= 250:
		verificar_logro("krits_boss_s")
	if krits_boss_totales >= 1000:
		verificar_logro("krits_boss_g")

func agregar_puntos(cantidad: int):
	var data = CHARACTER_DATA[selected_character]
	var mult = 1
	if data.has("pasiva") and data.pasiva.has("id") and data.pasiva.id == "doble_puntos":
		if data.pasiva.has("multiplicador"):
			mult = int(data.pasiva.multiplicador)
	puntos += cantidad * mult
	puntos_totales += cantidad * mult
	if puntos > puntos_run_max:
		puntos_run_max = puntos

	progreso_logros["puntos_total_b"] = puntos_totales
	progreso_logros["puntos_total_s"] = puntos_totales
	progreso_logros["puntos_total_g"] = puntos_totales
	progreso_logros["puntos_run_b"] = puntos_run_max
	progreso_logros["puntos_run_s"] = puntos_run_max
	progreso_logros["puntos_run_g"] = puntos_run_max
	if puntos_totales >= 25000:
		verificar_logro("puntos_total_b")
	if puntos_totales >= 250000:
		verificar_logro("puntos_total_s")
	if puntos_totales >= 1000000:
		verificar_logro("puntos_total_g")
	if max(puntos, puntos_run_max) >= 10000:
		verificar_logro("puntos_run_b")
	if max(puntos, puntos_run_max) >= 50000:
		verificar_logro("puntos_run_s")
	if max(puntos, puntos_run_max) >= 100000:
		verificar_logro("puntos_run_g")

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
	var count = 0
	for p in personajes_desbloqueados:
		if p:
			count += 1
	progreso_logros["desbloquear_b"] = count
	progreso_logros["desbloquear_s"] = count
	if count >= 2:
		verificar_logro("desbloquear_b")
	if count >= 3:
		verificar_logro("desbloquear_s")
	var todos = true
	for p in personajes_desbloqueados:
		if not p:
			todos = false
			break
	if todos:
		verificar_logro("coleccionista")

func actualizar_ciclo(ciclo: int):
	progreso_logros["superviviente"] = ciclo
	progreso_logros["amo_mazmorra"] = ciclo
	if ciclo >= 5:
		verificar_logro("superviviente")
	if ciclo >= 10:
		verificar_logro("amo_mazmorra")

func registrar_muerte_jugador():
	muertes_totales += 1
	progreso_logros["muertes_b"] = muertes_totales
	progreso_logros["muertes_s"] = muertes_totales
	progreso_logros["muertes_g"] = muertes_totales
	if muertes_totales >= 10:
		verificar_logro("muertes_b")
	if muertes_totales >= 100:
		verificar_logro("muertes_s")
	if muertes_totales >= 500:
		verificar_logro("muertes_g")
	reset_rachas()

func reset_rachas():
	racha_hits = 0
	racha_krits = 0

func registrar_racha_hit():
	racha_hits += 1
	progreso_logros["racha_hits_b"] = racha_hits
	progreso_logros["racha_hits_s"] = racha_hits
	progreso_logros["racha_hits_g"] = racha_hits
	if racha_hits >= 25:
		verificar_logro("racha_hits_b")
	if racha_hits >= 75:
		verificar_logro("racha_hits_s")
	if racha_hits >= 150:
		verificar_logro("racha_hits_g")
	if racha_hits > racha_hits_max:
		racha_hits_max = racha_hits

func registrar_racha_krit():
	racha_krits += 1
	progreso_logros["racha_krits_b"] = racha_krits
	progreso_logros["racha_krits_s"] = racha_krits
	progreso_logros["racha_krits_g"] = racha_krits
	if racha_krits >= 10:
		verificar_logro("racha_krits_b")
	if racha_krits >= 25:
		verificar_logro("racha_krits_s")
	if racha_krits >= 50:
		verificar_logro("racha_krits_g")
	if racha_krits > racha_krits_max:
		racha_krits_max = racha_krits

func registrar_congelado():
	congelados_totales += 1
	progreso_logros["mago_invierno"] = congelados_totales
	if congelados_totales >= 200:
		verificar_logro("mago_invierno")

func registrar_ejecucion():
	ejecuciones_totales += 1
	progreso_logros["ronin_ejecutor"] = ejecuciones_totales
	if ejecuciones_totales >= 50:
		verificar_logro("ronin_ejecutor")

func actualizar_tiempo(delta: float):
	tiempo_total += delta
	tiempo_run += delta
	if tiempo_run > tiempo_run_max:
		tiempo_run_max = tiempo_run
	var run_tiempo = max(tiempo_run, tiempo_run_max)
	progreso_logros["tiempo_total_b"] = int(tiempo_total)
	progreso_logros["tiempo_total_s"] = int(tiempo_total)
	progreso_logros["tiempo_total_g"] = int(tiempo_total)
	progreso_logros["tiempo_run_b"] = int(run_tiempo)
	progreso_logros["tiempo_run_s"] = int(run_tiempo)
	progreso_logros["tiempo_run_g"] = int(run_tiempo)
	if tiempo_total >= 3600:
		verificar_logro("tiempo_total_b")
	if tiempo_total >= 36000:
		verificar_logro("tiempo_total_s")
	if tiempo_total >= 180000:
		verificar_logro("tiempo_total_g")
	if run_tiempo >= 600:
		verificar_logro("tiempo_run_b")
	if run_tiempo >= 1200:
		verificar_logro("tiempo_run_s")
	if run_tiempo >= 2400:
		verificar_logro("tiempo_run_g")

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
	config.set_value("stats", "puntos_totales", puntos_totales)
	config.set_value("stats", "kills_run_max", kills_run_max)
	config.set_value("stats", "puntos_run_max", puntos_run_max)
	config.set_value("stats", "tiempo_total", tiempo_total)
	config.set_value("stats", "tiempo_run_max", tiempo_run_max)
	config.set_value("stats", "muertes_totales", muertes_totales)
	config.set_value("stats", "krits_boss_totales", krits_boss_totales)
	config.set_value("stats", "racha_hits_max", racha_hits_max)
	config.set_value("stats", "racha_krits_max", racha_krits_max)
	config.set_value("stats", "congelados_totales", congelados_totales)
	config.set_value("stats", "ejecuciones_totales", ejecuciones_totales)
	config.set_value("stats", "kills_por_personaje", kills_por_personaje)
	config.set_value("stats", "krits_por_personaje", krits_por_personaje)
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
	if config.has_section_key("stats", "puntos_totales"):
		puntos_totales = config.get_value("stats", "puntos_totales")
	if config.has_section_key("stats", "kills_run_max"):
		kills_run_max = config.get_value("stats", "kills_run_max")
	if config.has_section_key("stats", "puntos_run_max"):
		puntos_run_max = config.get_value("stats", "puntos_run_max")
	if config.has_section_key("stats", "tiempo_total"):
		tiempo_total = config.get_value("stats", "tiempo_total")
	if config.has_section_key("stats", "tiempo_run_max"):
		tiempo_run_max = config.get_value("stats", "tiempo_run_max")
	if config.has_section_key("stats", "muertes_totales"):
		muertes_totales = config.get_value("stats", "muertes_totales")
	if config.has_section_key("stats", "krits_boss_totales"):
		krits_boss_totales = config.get_value("stats", "krits_boss_totales")
	if config.has_section_key("stats", "racha_hits_max"):
		racha_hits_max = config.get_value("stats", "racha_hits_max")
	if config.has_section_key("stats", "racha_krits_max"):
		racha_krits_max = config.get_value("stats", "racha_krits_max")
	if config.has_section_key("stats", "congelados_totales"):
		congelados_totales = config.get_value("stats", "congelados_totales")
	if config.has_section_key("stats", "ejecuciones_totales"):
		ejecuciones_totales = config.get_value("stats", "ejecuciones_totales")
	if config.has_section_key("stats", "kills_por_personaje"):
		kills_por_personaje = config.get_value("stats", "kills_por_personaje")
	if config.has_section_key("stats", "krits_por_personaje"):
		krits_por_personaje = config.get_value("stats", "krits_por_personaje")
