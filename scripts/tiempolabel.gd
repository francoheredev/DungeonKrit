extends CanvasLayer

@onready var tiempo_label = $TiempoLabel
@onready var puntos_label = $puntos
@onready var kills_label = $Kills
@onready var krits_label = $Krits

var tiempo := 0

func _ready():
	tiempo_label.text = "00:00"
	puntos_label.text = "Puntos: 0"
	kills_label.text = "Kills: 0"
	krits_label.text = "Krits: 0"
	GameManager.reset()
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

	var minutos = tiempo / 60
	var segundos = tiempo % 60

	tiempo_label.text = "%02d:%02d" % [minutos, segundos]
