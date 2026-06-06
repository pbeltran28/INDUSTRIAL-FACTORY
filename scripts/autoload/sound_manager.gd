## sound_manager.gd - Sistema de sonido con música en loop
extends Node

var _music : AudioStreamPlayer
var _sfx   : Dictionary = {}
var _music_key : String = ""

func _ready() -> void:
	_music = AudioStreamPlayer.new()
	_music.volume_db = -12.0
	add_child(_music)
	# Reconectar loop cuando termina la pista
	_music.finished.connect(_on_music_finished)

	for k in ["jump", "collect", "death", "unlock", "lever"]:
		var p := AudioStreamPlayer.new()
		p.volume_db = -5.0
		add_child(p)
		_sfx[k] = p

func _on_music_finished() -> void:
	# Reiniciar la misma pista cuando termina → loop manual
	if _music.stream != null:
		_music.play()

func _load_stream(path: String) -> AudioStream:
	if ResourceLoader.exists(path):
		return load(path)
	return null

func play_music(key: String) -> void:
	if _music_key == key and _music.playing:
		return
	_music_key = key
	var stream := _load_stream("res://assets/audio/music_%s.wav" % key)
	if stream == null:
		return
	_music.stream = stream
	_music.play()

func stop_music() -> void:
	_music.stop()
	_music_key = ""

func play_sfx(key: String) -> void:
	if not _sfx.has(key):
		return
	var player : AudioStreamPlayer = _sfx[key]
	var path   : String = "res://assets/audio/sfx_%s.wav" % key
	var stream := _load_stream(path)
	if stream == null:
		return
	if player.stream != stream:
		player.stream = stream
	player.play()
