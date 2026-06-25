extends Control
@onready var krits_label = $Krits

func _process(_delta):

	krits_label.text = ": " + str(GameManager.krits)
func _on_menu_button_pressed():
	get_tree().change_scene_to_file("res://escenas/menú.tscn")
