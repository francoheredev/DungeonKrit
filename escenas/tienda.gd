extends Control

@onready var krits_label = $Krits
@onready var runas_label = $RunasLabel

var dialogo: Control = null
var botones_tienda: Array[Button] = []

const DATOS_PERSONAJES = [
	{indice = 1, btn = "ButtonPJ2"},
	{indice = 2, btn = "ButtonPJ1"},
	{indice = 3, btn = "ButtonPJ3"},
]

func _ready():
	for p in DATOS_PERSONAJES:
		var btn = get_node_or_null(p.btn)
		if btn:
			btn.pressed.connect(_abrir_confirmacion.bind(p.indice))
			botones_tienda.append(btn)

	for i in 3:
		var btn = get_node_or_null("ButtonRunas" + str(i + 1))
		if btn:
			btn.pressed.connect(_comprar_runas.bind(i))
			botones_tienda.append(btn)

func _process(_delta):
	krits_label.text = ": " + str(GameManager.krits_totales)
	runas_label.text = ": " + str(GameManager.runas)

func _set_botones_habilitados(habilitado: bool):
	for btn in botones_tienda:
		btn.disabled = not habilitado

func _abrir_confirmacion(indice: int):
	var data = GameManager.CHARACTER_DATA[indice]
	var precio_krits = GameManager.PRECIO_PERSONAJES[indice]
	var precio_runas = GameManager.PRECIO_RUNAS_PERSONAJES[indice]

	_set_botones_habilitados(false)

	dialogo = Control.new()
	dialogo.name = "DialogoConfirmacion"
	dialogo.anchors_preset = Control.PRESET_FULL_RECT
	dialogo.mouse_filter = Control.MOUSE_FILTER_STOP

	var fondo = ColorRect.new()
	fondo.color = Color(0, 0, 0, 0.7)
	fondo.size = dialogo.size
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dialogo.add_child(fondo)

	var panel = Panel.new()
	dialogo.add_child(panel)
	panel.position = Vector2(190, 460)
	panel.size = Vector2(700, 900)

	var portada = TextureRect.new()
	portada.texture = load("res://Arte/pj" + str(indice + 1) + ".png")
	portada.position = Vector2(155,150)
	portada.size = Vector2(150, 150)
	portada.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	panel.add_child(portada)

	var nombre = Label.new()
	nombre.text = data.name
	nombre.position = Vector2(0, 550)
	nombre.size = Vector2(700, 50)
	nombre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nombre.add_theme_font_size_override("font_size", 40)
	panel.add_child(nombre)

	var precio_texto = ""
	if precio_krits > 0:
		precio_texto = "Precio: " + str(precio_krits) + " Krits  |  Saldo: " + str(GameManager.krits_totales)
	else:
		precio_texto = "Precio: " + str(precio_runas) + " Runas  |  Saldo: " + str(GameManager.runas)

	var precio_label = Label.new()
	precio_label.text = precio_texto
	precio_label.position = Vector2(0, 620)
	precio_label.size = Vector2(700, 50)
	precio_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	precio_label.add_theme_font_size_override("font_size", 30)
	panel.add_child(precio_label)

	var mono_label = Label.new()
	mono_label.text = "¿Comprar este personaje?"
	mono_label.position = Vector2(0, 690)
	mono_label.size = Vector2(700, 50)
	mono_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mono_label.add_theme_font_size_override("font_size", 26)
	panel.add_child(mono_label)

	var btn_hbox = HBoxContainer.new()
	btn_hbox.position = Vector2(250, 770)
	btn_hbox.size = Vector2(200, 60)
	btn_hbox.add_theme_constant_override("separation", 40)
	panel.add_child(btn_hbox)

	var btn_comprar = Button.new()
	btn_comprar.text = "COMPRAR"
	btn_comprar.custom_minimum_size = Vector2(80, 50)
	btn_comprar.pressed.connect(_confirmar_compra.bind(indice))
	btn_hbox.add_child(btn_comprar)

	var btn_cancelar = Button.new()
	btn_cancelar.text = "CANCELAR"
	btn_cancelar.custom_minimum_size = Vector2(110, 50)
	btn_cancelar.pressed.connect(_cerrar_dialogo)
	btn_hbox.add_child(btn_cancelar)

	add_child(dialogo)

func _confirmar_compra(indice: int):
	if GameManager.comprar_personaje(indice):
		_cerrar_dialogo()

func _cerrar_dialogo():
	if dialogo:
		dialogo.queue_free()
		dialogo = null
		_set_botones_habilitados(true)

func _comprar_runas(paquete_idx: int):
	GameManager.comprar_runas(paquete_idx)

func _on_menu_button_pressed():
	AudioManager.play_menu_regresar()
	get_tree().change_scene_to_file("res://escenas/menú.tscn")
