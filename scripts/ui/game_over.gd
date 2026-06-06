## game_over.gd - Pantalla final con confeti, ganador en grande y estadísticas
extends Control

var _confetti_nodes : Array = []
var _time           : float = 0.0
var _winner_pid     : int   = -1   # -1 = empate

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	SoundManager.stop_music()
	_determine_winner()
	_build_ui()
	_spawn_confetti()
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.8)

func _determine_winner() -> void:
	var s0 : int = GameManager.get_score(0)
	var s1 : int = GameManager.get_score(1)
	if   s0 > s1: _winner_pid = 0
	elif s1 > s0: _winner_pid = 1
	else:         _winner_pid = -1  # empate

func _build_ui() -> void:
	# ── Fondo oscuro ──────────────────────────────────────────────
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.04, 0.03, 0.08)
	add_child(bg)

	# ── GANADOR en letras GRANDES (centro superior) ───────────────
	var winner_color : Color
	var winner_text  : String
	match _winner_pid:
		0:
			winner_text  = "¡GANA JUGADOR 1!"
			winner_color = Color(1.0, 0.65, 0.08)
		1:
			winner_text  = "¡GANA JUGADOR 2!"
			winner_color = Color(0.35, 0.75, 1.0)
		_:
			winner_text  = "¡EMPATE!"
			winner_color = Color(1.0, 0.92, 0.28)

	# Sombra del texto ganador
	var shadow_lbl := Label.new()
	shadow_lbl.text = winner_text
	shadow_lbl.set_anchor(SIDE_LEFT, 0.5); shadow_lbl.set_anchor(SIDE_RIGHT, 0.5)
	shadow_lbl.offset_left = -502; shadow_lbl.offset_right = 502; shadow_lbl.offset_top = 32
	shadow_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shadow_lbl.add_theme_font_size_override("font_size", 72)
	shadow_lbl.add_theme_color_override("font_color", Color(0, 0, 0, 0.5))
	add_child(shadow_lbl)

	# Texto principal ganador
	var winner_lbl := Label.new()
	winner_lbl.text = winner_text
	winner_lbl.set_anchor(SIDE_LEFT, 0.5); winner_lbl.set_anchor(SIDE_RIGHT, 0.5)
	winner_lbl.offset_left = -500; winner_lbl.offset_right = 500; winner_lbl.offset_top = 28
	winner_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	winner_lbl.add_theme_font_size_override("font_size", 72)
	winner_lbl.add_theme_color_override("font_color", winner_color)
	add_child(winner_lbl)

	# Animación de pulso en el ganador
	var pulse := create_tween()
	pulse.set_loops()
	pulse.tween_property(winner_lbl, "scale", Vector2(1.05, 1.05), 0.6).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(winner_lbl, "scale", Vector2(1.0,  1.0),  0.6).set_trans(Tween.TRANS_SINE)

	# Subtítulo "GAME OVER"
	var go_lbl := Label.new()
	go_lbl.text = "— GAME OVER —"
	go_lbl.set_anchor(SIDE_LEFT, 0.5); go_lbl.set_anchor(SIDE_RIGHT, 0.5)
	go_lbl.offset_left = -300; go_lbl.offset_right = 300; go_lbl.offset_top = 112
	go_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	go_lbl.add_theme_font_size_override("font_size", 28)
	go_lbl.add_theme_color_override("font_color", Color(0.65, 0.22, 0.22))
	add_child(go_lbl)

	# ── Separador ─────────────────────────────────────────────────
	var sep := ColorRect.new()
	sep.set_anchor(SIDE_LEFT, 0.5); sep.set_anchor(SIDE_RIGHT, 0.5)
	sep.offset_left = -520; sep.offset_right = 520
	sep.offset_top  = 154;  sep.offset_bottom = 157
	sep.color = Color(0.5, 0.38, 0.12)
	add_child(sep)

	# ── Tarjetas de estadísticas (lado a lado) ────────────────────
	_build_player_card(0, 168, Color(1.0, 0.62, 0.10))
	_build_player_card(1, 168, Color(0.35, 0.72, 1.0))

	# ── Separador inferior ────────────────────────────────────────
	var sep2 := ColorRect.new()
	sep2.set_anchor(SIDE_LEFT, 0.5); sep2.set_anchor(SIDE_RIGHT, 0.5)
	sep2.offset_left = -520; sep2.offset_right = 520
	sep2.offset_top  = 512;  sep2.offset_bottom = 515
	sep2.color = Color(0.5, 0.38, 0.12)
	add_child(sep2)

	# ── Botones ───────────────────────────────────────────────────
	_btn("🔄   REINTENTAR",    Color(1.0, 0.62, 0.10), 530, "_on_retry")
	_btn("🏠   MENÚ PRINCIPAL",Color(0.45, 0.78, 1.0),  600, "_on_menu")

func _build_player_card(pid: int, start_y: float, accent: Color) -> void:
	var s0 : int = GameManager.get_score(pid)
	var parts    : int = GameManager.stats_parts[pid]
	var gears    : int = GameManager.stats_gears[pid]
	var enemies  : int = GameManager.stats_enemies[pid]
	var levels_c : int = GameManager.stats_levels[pid]

	# Posición: P1 = izquierda, P2 = derecha
	var card_left  : float = 60.0  if pid == 0 else 660.0
	var card_right : float = 620.0 if pid == 0 else 1220.0

	# Fondo de la tarjeta
	var card_bg := ColorRect.new()
	card_bg.offset_left   = card_left
	card_bg.offset_right  = card_right
	card_bg.offset_top    = start_y
	card_bg.offset_bottom = start_y + 336
	card_bg.color = Color(accent.r * 0.08, accent.g * 0.08, accent.b * 0.08, 0.9)
	add_child(card_bg)

	# Borde superior de color
	var card_top := ColorRect.new()
	card_top.offset_left   = card_left
	card_top.offset_right  = card_right
	card_top.offset_top    = start_y
	card_top.offset_bottom = start_y + 4
	card_top.color = accent
	add_child(card_top)

	# Nombre del jugador
	_stat_lbl("JUGADOR %d" % (pid + 1),
		card_left, start_y + 12, card_right, 22, accent, true)

	# Puntaje total — prominente
	_stat_lbl("%d pts" % s0,
		card_left, start_y + 42, card_right, 48, Color(1.0, 1.0, 1.0), true)

	# Línea divisora interna
	var inner_sep := ColorRect.new()
	inner_sep.offset_left   = card_left + 20
	inner_sep.offset_right  = card_right - 20
	inner_sep.offset_top    = start_y + 102
	inner_sep.offset_bottom = start_y + 104
	inner_sep.color = Color(accent.r, accent.g, accent.b, 0.3)
	add_child(inner_sep)

	# Detalle de estadísticas
	var stats := [
		["⚙  Piezas recogidas", str(parts)],
		["★  Engranajes dorados", str(gears)],
		["🤖  Enemigos eliminados", str(enemies)],
		["🏆  Niveles completados", str(levels_c)],
	]
	for i in stats.size():
		var y := start_y + 116.0 + i * 50.0
		_stat_lbl(stats[i][0], card_left + 20, y, card_right - 120, 16, Color(0.8, 0.8, 0.85))
		_stat_lbl(stats[i][1], card_right - 110, y, card_right - 10, 22, accent, true)

	# Indicador de ganador en la tarjeta
	if _winner_pid == pid:
		var crown := Label.new()
		crown.text = "🏆"
		crown.offset_left = card_right - 60
		crown.offset_top  = start_y + 4
		crown.add_theme_font_size_override("font_size", 36)
		add_child(crown)

func _stat_lbl(text: String, lx: float, ly: float, rx: float,
               fs: int, color: Color, bold: bool = false) -> void:
	var l := Label.new()
	l.text = text
	l.offset_left  = lx
	l.offset_top   = ly
	l.offset_right = rx
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", color)
	if bold:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(l)

func _btn(text: String, color: Color, cy: float, method: String) -> void:
	var bg := ColorRect.new()
	bg.set_anchor(SIDE_LEFT, 0.5); bg.set_anchor(SIDE_RIGHT, 0.5)
	bg.offset_left  = -200; bg.offset_right  = 200
	bg.offset_top   = cy;   bg.offset_bottom = cy + 58
	bg.color = Color(color.r * 0.14, color.g * 0.14, color.b * 0.14, 0.9)
	add_child(bg)
	var btn := Button.new()
	btn.text = text
	btn.set_anchor(SIDE_LEFT, 0.5); btn.set_anchor(SIDE_RIGHT, 0.5)
	btn.offset_left  = -200; btn.offset_right  = 200
	btn.offset_top   = cy;   btn.offset_bottom = cy + 58
	btn.add_theme_font_size_override("font_size", 20)
	btn.add_theme_color_override("font_color", color)
	btn.pressed.connect(Callable(self, method))
	add_child(btn)

# ── CONFETI ───────────────────────────────────────────────────────
func _spawn_confetti() -> void:
	var colors : Array[Color] = [
		Color(1.0, 0.2, 0.2),   # rojo
		Color(1.0, 0.8, 0.1),   # dorado
		Color(0.2, 0.8, 0.4),   # verde
		Color(0.3, 0.6, 1.0),   # azul
		Color(1.0, 0.4, 0.8),   # rosa
		Color(0.9, 0.5, 0.1),   # naranja
		Color(0.8, 0.3, 1.0),   # morado
	]
	# Crear 80 piezas de confeti
	for i in range(80):
		var piece := _make_confetti_piece(colors[i % colors.size()])
		add_child(piece)
		_confetti_nodes.append(piece)

func _make_confetti_piece(color: Color) -> Control:
	var piece := ColorRect.new()
	# Tamaño aleatorio (rectángulo o cuadrado)
	var w : float = randf_range(6, 14)
	var h : float = randf_range(4, 10)
	piece.size  = Vector2(w, h)
	piece.color = color

	# Posición inicial aleatoria en la parte superior
	piece.position = Vector2(
		randf_range(0, 1280),
		randf_range(-200, -10)
	)

	# Propiedades de caída
	piece.set_meta("vel_x",   randf_range(-80, 80))
	piece.set_meta("vel_y",   randf_range(120, 280))
	piece.set_meta("rot_spd", randf_range(-3.0, 3.0))
	piece.set_meta("wave",    randf_range(0, TAU))
	piece.set_meta("delay",   randf_range(0.0, 2.5))
	return piece

func _process(delta: float) -> void:
	_time += delta
	for piece in _confetti_nodes:
		if not is_instance_valid(piece): continue
		var delay : float = piece.get_meta("delay")
		if _time < delay: continue

		var t : float = _time - delay
		var vx : float = piece.get_meta("vel_x")
		var vy : float = piece.get_meta("vel_y")
		var rs : float = piece.get_meta("rot_spd")
		var wv : float = piece.get_meta("wave")

		# Movimiento ondulante
		var new_x : float = piece.position.x + (vx + sin(_time * 1.5 + wv) * 40) * delta
		var new_y : float = piece.position.y + vy * delta
		piece.position = Vector2(new_x, new_y)
		piece.rotation += rs * delta

		# Reciclar al salir por abajo
		if piece.position.y > 750:
			piece.position = Vector2(randf_range(0, 1280), randf_range(-80, -5))
			piece.set_meta("delay", 0.0)

func _on_retry() -> void:
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://scenes/nivel1.tscn")

func _on_menu() -> void:
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
