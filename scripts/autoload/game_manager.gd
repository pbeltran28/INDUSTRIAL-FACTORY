## GameManager.gd - Singleton Autoload (Guia 10)
extends Node

signal score_changed(pid:int, val:int)
signal lives_changed(pid:int, val:int)
signal parts_changed(pid:int, val:int)
signal current_player_changed(pid:int)

const MAX_LIVES            := 3
const PARTS_TO_UNLOCK_EXIT := 10
const PART_POINTS          := 100
const GEAR_POINTS          := 500
const ENEMY_POINTS         := 200

var player_lives  : Array[int] = [3, 3]
var player_scores : Array[int] = [0, 0]
var player_parts  : Array[int] = [0, 0]

var stats_parts   : Array[int] = [0, 0]
var stats_gears   : Array[int] = [0, 0]
var stats_enemies : Array[int] = [0, 0]
var stats_levels  : Array[int] = [0, 0]

var current_player : int = 0
var current_level  : int = 1

# Flag: indica si el nivel debe recargarse completamente para P2
var reload_level_for_next_player : bool = false

func _process(_d: float) -> void:
	if Input.is_action_just_pressed("save_game"): SaveManager.save_game()
	if Input.is_action_just_pressed("load_game"): SaveManager.load_game()

func reset_game() -> void:
	player_lives   = [MAX_LIVES, MAX_LIVES]
	player_scores  = [0, 0]
	player_parts   = [0, 0]
	stats_parts    = [0, 0]
	stats_gears    = [0, 0]
	stats_enemies  = [0, 0]
	stats_levels   = [0, 0]
	current_player = 0
	current_level  = 1
	reload_level_for_next_player = false

func reset_current_player_parts() -> void:
	player_parts[current_player] = 0
	parts_changed.emit(current_player, 0)

func add_score(pid: int, v: int) -> void:
	player_scores[pid] += v
	score_changed.emit(pid, player_scores[pid])

func get_score(pid: int) -> int:
	return player_scores[pid]

func add_part(pid: int) -> void:
	player_parts[pid] += 1
	stats_parts[pid]  += 1
	add_score(pid, PART_POINTS)
	parts_changed.emit(pid, player_parts[pid])
	SoundManager.play_sfx("collect")
	if player_parts[pid] >= PARTS_TO_UNLOCK_EXIT:
		get_tree().call_group("exit_doors", "unlock")

func add_gear(pid: int) -> void:
	stats_gears[pid] += 1
	add_score(pid, GEAR_POINTS)
	SoundManager.play_sfx("collect")

func get_parts(pid: int) -> int:
	return player_parts[pid]

func is_exit_unlocked() -> bool:
	return player_parts[current_player] >= PARTS_TO_UNLOCK_EXIT

func get_lives(pid: int) -> int:
	return player_lives[pid]

func lose_life(pid: int) -> void:
	player_lives[pid] = max(0, player_lives[pid] - 1)
	lives_changed.emit(pid, player_lives[pid])
	SoundManager.play_sfx("death")
	if player_lives[pid] <= 0:
		_player_out(pid)

func _player_out(pid: int) -> void:
	var other : int = 1 - pid
	if player_lives[other] > 0:
		current_player = other
		# Resetear piezas de P2 a 0
		player_parts[other] = 0
		parts_changed.emit(other, 0)
		# Recargar el nivel COMPLETO para que P2 encuentre todas las piezas
		await get_tree().create_timer(1.5).timeout
		current_player_changed.emit(other)
		get_tree().reload_current_scene()
	else:
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")

func complete_level() -> void:
	stats_levels[current_player] += 1
	current_level += 1
	await get_tree().create_timer(1.5).timeout
	if current_level > 3:
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	else:
		player_parts[current_player] = 0
		get_tree().change_scene_to_file(
			"res://scenes/nivel%d.tscn" % current_level)
