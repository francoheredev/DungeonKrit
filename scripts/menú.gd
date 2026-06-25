extends Control
@onready var krits_label = $Krits

func _process(_delta):

	krits_label.text = ": " + str(GameManager.krits)
func _on_jugar_button_pressed():
	get_tree().change_scene_to_file("res://escenas/gameplay.tscn")

func _on_tienda_button_pressed():
	get_tree().change_scene_to_file("res://escenas/tienda.tscn")
	
func _on_config_button_pressed():
	get_tree().change_scene_to_file("res://escenas/config.tscn")

func _on_logros_button_pressed():
	get_tree().change_scene_to_file("res://escenas/logros.tscn")
	
func _on_info_button_pressed():
	print ("info")
