extends Node

var _player: AudioStreamPlayer

func _ready():
	_player = AudioStreamPlayer.new()
	add_child(_player)

func play(sound_path: String):
	var stream = load(sound_path)
	if stream:
		_player.stream = stream
		_player.play()

func play_menu_boton1():
	play("res://sonidos/menu/boton1.ogg")

func play_menu_boton2():
	play("res://sonidos/menu/boton2.ogg")

func play_menu_regresar():
	play("res://sonidos/menu/boton_regre.ogg")

func play_arco():
	play("res://sonidos/gameplay/arco.ogg")

func play_kunai():
	play("res://sonidos/gameplay/kunai.ogg")

func play_hielo():
	play("res://sonidos/gameplay/hielo.ogg")

func play_cuchi():
	play("res://sonidos/gameplay/cuchi.ogg")

func play_muerte_pj():
	play("res://sonidos/gameplay/muerte_pj.ogg")

func play_muerte_enemigo():
	play("res://sonidos/gameplay/muerte_enemigo.ogg")

func play_dano_enemigo():
	play("res://sonidos/gameplay/dano_enemigo.ogg")
