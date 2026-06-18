extends Control
@onready var krits_label = $Krits

func _process(_delta):

	krits_label.text = ": " + str(GameManager.krits)
func _on_jugar_button_pressed():
	get_tree().change_scene_to_file("res://escenas/gameplay.tscn")

func _on_tienda_button_pressed():
	print("Abrir tienda")

func _on_salir_button_pressed():
	get_tree().quit()
