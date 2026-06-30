extends Control

var tiempo_restante := 5.0
var activo := false
var escala_base := Vector2.ONE
var tween_corazon: Tween

func costo_actual() -> int:
	return 50 * (1 << GameManager.contador_resurrecciones)

func mostrar():
	escala_base = Vector2(0.155, 0.155)
	$Corazon.scale = escala_base
	$Corazon.pivot_offset = $Corazon.size / 2
	visible = true
	get_tree().paused = true
	activo = true
	tiempo_restante = 5.0
	$"../BlurOverlay".visible = true
	$CostoLabel.text = "%d RUNAS - 5s" % costo_actual()

	if tween_corazon and tween_corazon.is_valid():
		tween_corazon.kill()
	tween_corazon = create_tween().set_loops()
	tween_corazon.tween_property($Corazon, "scale", escala_base * 1.15, 0.4)
	tween_corazon.tween_property($Corazon, "scale", escala_base, 0.4)

func _process(delta):
	if not activo:
		return
	tiempo_restante -= delta
	var s = ceili(tiempo_restante)
	if s >= 0:
		$CostoLabel.text = "%d RUNAS - %ds" % [costo_actual(), s]
	if tiempo_restante <= 0:
		_ir_al_menu()

func _on_revivir_button_pressed():
	if not activo:
		return
	var costo = costo_actual()
	if GameManager.runas >= costo:
		_limpiar()
		GameManager.runas -= costo
		GameManager.contador_resurrecciones += 1
		GameManager.verificar_logro("regreso")
		GameManager.guardar_datos()
		get_tree().paused = false
		visible = false
		var jugador = get_tree().get_first_node_in_group("jugador")
		if jugador and jugador.has_method("revivir"):
			jugador.revivir()
	else:
		$CostoLabel.text = "¡NO TENES RUNAS SUFICIENTES!"

func _on_menu_button_pressed():
	_ir_al_menu()

func _ir_al_menu():
	_limpiar()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://escenas/menú.tscn")

func _limpiar():
	activo = false
	$"../BlurOverlay".visible = false
	if tween_corazon and tween_corazon.is_valid():
		tween_corazon.kill()
