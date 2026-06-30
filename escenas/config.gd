extends Control

const RUTA := "user://settings.cfg"

@onready var slider = $VBox/Volumen/Slider
@onready var label_valor = $VBox/Volumen/Valor

func _ready():
	cargar()
	slider.value_changed.connect(_on_volumen_changed)

func _on_volumen_changed(val: float):
	label_valor.text = "%d%%" % val
	AudioServer.set_bus_volume_db(0, linear_to_db(val / 100.0))
	guardar()

func guardar():
	var cfg = ConfigFile.new()
	cfg.set_value("audio", "volumen", slider.value)
	cfg.save(RUTA)

func cargar():
	var cfg = ConfigFile.new()
	if cfg.load(RUTA) != OK:
		slider.value = 100
		return
	slider.value = cfg.get_value("audio", "volumen", 100)

func _on_menu_button_pressed():
	AudioManager.play_menu_regresar()
	get_tree().change_scene_to_file("res://escenas/menú.tscn")
