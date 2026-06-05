extends CanvasLayer

@onready var tiempo_label = $TiempoLabel
@onready var timer = $"../Timer"

var tiempo := 0


func _on_tiempo_timer_timeout():
	tiempo += 1

	var minutos = tiempo / 60
	var segundos = tiempo % 60

	tiempo_label.text = "%02d:%02d" % [minutos, segundos]

func _on_timer_timeout() -> void:
	pass # Replace with function body.
