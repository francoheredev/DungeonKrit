extends Control

func _on_jugar_button_pressed():
	get_tree().change_scene_to_file("res://escenas/gameplay.tscn")

func _on_tienda_button_pressed():
	print("Abrir tienda")

func _on_salir_button_pressed():
	get_tree().quit()
