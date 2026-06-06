## test_game_logic.gd - Pruebas Unitarias (Guia 14)
## Para ejecutar con GUT: instala el plugin y cambia la linea extends a:
##   extends "res://addons/gut/test.gd"
## Sin GUT: ejecuta run_all_tests() manualmente desde el editor.
extends Node

var _passed : int = 0
var _failed : int = 0

func _ready() -> void:
	# Auto-ejecutar al correr la escena de debug
	run_all_tests()

func run_all_tests() -> void:
	print("=== TESTS (Guia 14) ===")
	_passed = 0
	_failed = 0
	test_is_prime()
	test_game_manager_initial()
	test_add_score()
	test_lose_life()
	test_parts_unlock()
	print("Resultado: %d OK, %d FAIL" % [_passed, _failed])

func _assert(condition: bool, msg: String) -> void:
	if condition:
		print("  PASS: " + msg)
		_passed += 1
	else:
		printerr("  FAIL: " + msg)
		_failed += 1

# ─── Funcion prima ────────────────────────────────────────────────────────────
func is_prime(n: int) -> bool:
	if n < 2:
		return false
	if n == 2:
		return true
	if n % 2 == 0:
		return false
	var i : int = 3
	while i * i <= n:
		if n % i == 0:
			return false
		i += 2
	return true

func test_is_prime() -> void:
	print("-- test_is_prime --")
	_assert(is_prime(2)  == true,  "2 es primo")
	_assert(is_prime(3)  == true,  "3 es primo")
	_assert(is_prime(7)  == true,  "7 es primo")
	_assert(is_prime(11) == true,  "11 es primo")
	_assert(is_prime(0)  == false, "0 no es primo")
	_assert(is_prime(1)  == false, "1 no es primo")
	_assert(is_prime(4)  == false, "4 no es primo")
	_assert(is_prime(15) == false, "15 no es primo")
	_assert(is_prime(25) == false, "25 no es primo")

func test_game_manager_initial() -> void:
	print("-- test_game_manager_initial --")
	GameManager.reset_game()
	_assert(GameManager.get_lives(0)   == 3, "P1 inicia con 3 vidas")
	_assert(GameManager.get_lives(1)   == 3, "P2 inicia con 3 vidas")
	_assert(GameManager.get_score(0)   == 0, "P1 score = 0")
	_assert(GameManager.current_level  == 1, "Nivel inicial = 1")

func test_add_score() -> void:
	print("-- test_add_score --")
	GameManager.reset_game()
	GameManager.add_score(0, 150)
	_assert(GameManager.get_score(0) == 150, "Score P1 = 150")
	GameManager.add_score(0, 50)
	_assert(GameManager.get_score(0) == 200, "Score P1 = 200")

func test_lose_life() -> void:
	print("-- test_lose_life --")
	GameManager.reset_game()
	GameManager.player_lives[0] = 3
	GameManager.player_lives[0] -= 1
	_assert(GameManager.player_lives[0] == 2, "P1 tiene 2 vidas tras perder 1")

func test_parts_unlock() -> void:
	print("-- test_parts_unlock --")
	GameManager.reset_game()
	var needed : int = GameManager.PARTS_TO_UNLOCK_EXIT
	GameManager.player_parts[GameManager.current_player] = needed
	_assert(GameManager.is_exit_unlocked(), "Salida desbloqueada con %d piezas" % needed)
