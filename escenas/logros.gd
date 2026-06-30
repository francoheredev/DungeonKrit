extends Control
@onready var krits_label = $Krits
@onready var runas_label = $RunasLabel

const ITEM_TEMPLATE = preload("res://escenas/logro_item.tscn")

func _ready():
	_crear_items()
	_actualizar_logros()

func _crear_items():
	var lista = $ScrollContainer/Lista
	for child in lista.get_children():
		lista.remove_child(child)
		child.queue_free()
	for l in GameManager.LOGROS:
		var item = ITEM_TEMPLATE.instantiate()
		item.name = l.id
		lista.add_child(item)
		var btn = Button.new()
		btn.name = "ReclamarBtn"
		btn.visible = false
		btn.text = "RECLAMAR"
		btn.size_flags_horizontal = Control.SIZE_EXPAND
		btn.flat = true
		item.add_child(btn)

func _process(_delta):
	krits_label.text = ": " + str(GameManager.krits_totales)
	runas_label.text = ": " + str(GameManager.runas)

func _actualizar_logros():
	for item in $ScrollContainer/Lista.get_children():
		var id = item.name
		var l = _buscar_logro(id)
		if l == null:
			continue
		var desbloqueado = GameManager.logros_desbloqueados.has(id) and GameManager.logros_desbloqueados[id]
		var reclamado = GameManager.logros_reclamados.has(id) and GameManager.logros_reclamados[id]
		var estado = item.get_node("Estado")
		var nombre = item.get_node("VBox/Nombre")
		var descripcion = item.get_node("VBox/Descripcion")
		var barra = item.get_node("VBox/Barra")
		var btn = item.get_node("ReclamarBtn")

		nombre.text = l.name
		var desc = l.desc
		if l.has("recompensa") and l.recompensa.has("runas"):
			desc += " (+%d runas)" % l.recompensa.runas
		descripcion.text = desc

		if desbloqueado:
			estado.text = "✓"
			item.modulate = Color(1, 1, 1, 1)
		else:
			estado.text = "✗"
			item.modulate = Color(1, 1, 1, 0.55)

		if l.has("recompensa") and l.recompensa.has("runas"):
			if desbloqueado and not reclamado:
				btn.visible = true
				btn.text = "RECLAMAR %+d" % l.recompensa.runas
				if not btn.is_connected("pressed", Callable(self, "_on_reclamar_pressed")):
					btn.pressed.connect(_on_reclamar_pressed.bind(id, btn))
			elif reclamado:
				btn.visible = true
				btn.text = "RECLAMADO"
				btn.disabled = true
			else:
				btn.visible = false
		else:
			btn.visible = false

		if l.has("max"):
			var prog = GameManager.progreso_logros.get(id, 0)
			var ratio = float(prog) / float(l.max)
			ratio = min(ratio, 1.0)
			var bg = barra.get_node("Bg")
			var fill = barra.get_node("Fill")
			var rombo = item.get_node("Rombo")
			fill.set_meta("ratio", ratio)
			fill.set_meta("rombo", rombo)
		else:
			barra.visible = false

	await get_tree().process_frame
	for item in $ScrollContainer/Lista.get_children():
		var barra = item.get_node("VBox/Barra")
		if not barra.visible:
			continue
		var bg = barra.get_node("Bg")
		var fill = barra.get_node("Fill")
		var rombo = fill.get_meta("rombo", null)
		if rombo == null:
			continue
		var ratio = fill.get_meta("ratio", 0.0)
		var bg_rect = bg.get_global_rect()
		var ancho_util = bg_rect.size.x
		fill.offset_right = fill.offset_left + ancho_util * ratio
		rombo.global_position.x = bg_rect.position.x + ancho_util * ratio
		rombo.global_position.y = bg_rect.get_center().y

func _on_reclamar_pressed(id: String, btn: Button):
	if GameManager.reclamar_recompensa(id):
		btn.text = "RECLAMADO"
		btn.disabled = true

func _buscar_logro(id: String):
	for l in GameManager.LOGROS:
		if l.id == id:
			return l
	return null

func _on_menu_button_pressed():
	AudioManager.play_menu_regresar()
	get_tree().change_scene_to_file("res://escenas/menú.tscn")
