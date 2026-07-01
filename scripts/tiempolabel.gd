extends CanvasLayer

@onready var tiempo_label = $TiempoLabel
@onready var puntos_label = $puntos
@onready var kills_label = $Kills
@onready var krits_label = $Krits
@onready var tip_label = $TipLabel

var tiempo := 0

func _ready():
	tiempo_label.text = "00:00"
	puntos_label.text = "Puntos: 0"
	kills_label.text = "Kills: 0"
	krits_label.text = "Krits: 0"
	GameManager.reset()
	_mostrar_tip()

func _mostrar_tip():
	var tips = [
		"¡NO GOLPEES LAS BALAS QUE YA ESTÁN EN EL ENEMIGO!",
		"¡LAS BALAS CLAVADAS TAMBIÉN TE HACEN DAÑO!",
		"¡CUIDADO CON TUS PROPIAS BALAS!",
	]
	tip_label.text = tips.pick_random()
	tip_label.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(tip_label, "modulate", Color(1, 1, 1, 1), 0.5)
	tween.tween_interval(2.5)
	tween.tween_property(tip_label, "modulate", Color(1, 1, 1, 0), 1.0)
	await tween.finished
	tip_label.hide()
func _process(_delta):
	puntos_label.text = "Puntos: " + str(GameManager.puntos)
	kills_label.text = "Kills: " + str(GameManager.kills)
	krits_label.text = "Krits: " + str(GameManager.krits)

func _on_pausa_button_pressed():
	get_tree().paused = true
	$PausaButton.visible = false
	$MenuPausa._mostrar()

func _on_tiempo_timer_timeout():
	tiempo += 1

	var minutos = int(tiempo / 60.0)
	var segundos = tiempo % 60

	tiempo_label.text = "%02d:%02d" % [minutos, segundos]
	GameManager.actualizar_tiempo(1.0)
