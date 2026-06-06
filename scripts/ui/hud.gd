## hud.gd - HUD rediseñado: más grande, más legible, bold-style
extends CanvasLayer

var _lbl : Dictionary = {}

func _ready() -> void:
	_build()
	GameManager.score_changed.connect(_on_score)
	GameManager.lives_changed.connect(_on_lives)
	GameManager.parts_changed.connect(_on_parts)
	GameManager.current_player_changed.connect(_on_player)
	_refresh_all()

func _build() -> void:
	# Panel fondo más alto para dar espacio
	var panel := ColorRect.new()
	panel.set_anchor(SIDE_LEFT,  0.0)
	panel.set_anchor(SIDE_RIGHT, 1.0)
	panel.offset_top    = 0
	panel.offset_bottom = 82
	panel.color = Color(0.03, 0.03, 0.07, 0.95)
	add_child(panel)

	# Línea inferior dorada
	var line := ColorRect.new()
	line.set_anchor(SIDE_LEFT,  0.0)
	line.set_anchor(SIDE_RIGHT, 1.0)
	line.offset_top    = 80
	line.offset_bottom = 84
	line.color = Color(0.60, 0.45, 0.12)
	add_child(line)

	# Divisores verticales izquierdo y derecho
	for xd in [380.0, 900.0]:
		var dv := ColorRect.new()
		dv.offset_left   = xd;      dv.offset_right  = xd + 2
		dv.offset_top    = 4;       dv.offset_bottom = 78
		dv.color = Color(0.45, 0.35, 0.12, 0.6)
		add_child(dv)

	# ── BLOQUE JUGADOR 1 (izquierda) ──────────────────────────────
	_mk("p1name", "JUGADOR 1",  12, 6,  13, Color(1.0,  0.60, 0.10))
	_mk("score0", "0 pts",      12, 24, 20, Color(0.95, 0.95, 1.0))
	_mk("lives0", "♥  ♥  ♥",   12, 52, 24, Color(1.0,  0.25, 0.30))

	# ── BLOQUE CENTRAL ────────────────────────────────────────────
	_mk_c("level_lbl",  "NIVEL 1",     5,  13, Color(0.65, 0.65, 0.70))
	_mk_c("parts_lbl",  "piezas 0/5", 22,  26, Color(1.0,  0.88, 0.22))
	_mk_c("player_lbl", "▶ J1 ACTIVO",56,  13, Color(1.0,  1.0,  0.28))

	# ── BLOQUE JUGADOR 2 (derecha) ────────────────────────────────
	_mk_r("p2name", "JUGADOR 2",   6,  13, Color(0.35, 0.72, 1.0))
	_mk_r("score1", "0 pts",      24,  20, Color(0.95, 0.95, 1.0))
	_mk_r("lives1", "♥  ♥  ♥",   52,  24, Color(0.35, 0.58, 1.0))

# ── HELPERS ───────────────────────────────────────────────────────
func _mk(key: String, text: String, ox: float, oy: float,
		 fs: int, color: Color) -> void:
	var l := Label.new()
	l.text        = text
	l.offset_left = ox
	l.offset_top  = oy
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", color)
	add_child(l)
	_lbl[key] = l

func _mk_c(key: String, text: String, oy: float,
		   fs: int, color: Color) -> void:
	var l := Label.new()
	l.text = text
	l.set_anchor(SIDE_LEFT,  0.5)
	l.set_anchor(SIDE_RIGHT, 0.5)
	l.offset_left  = -260
	l.offset_right =  260
	l.offset_top   = oy
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", color)
	add_child(l)
	_lbl[key] = l

func _mk_r(key: String, text: String, oy: float,
		   fs: int, color: Color) -> void:
	var l := Label.new()
	l.text = text
	l.set_anchor(SIDE_LEFT,  1.0)
	l.set_anchor(SIDE_RIGHT, 1.0)
	l.offset_left  = -370
	l.offset_right =  -12
	l.offset_top   = oy
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", color)
	add_child(l)
	_lbl[key] = l

# ── CALLBACKS ─────────────────────────────────────────────────────
func _on_score(pid: int, val: int) -> void:
	var key := "score%d" % pid
	if _lbl.has(key):
		_lbl[key].text = "%d pts" % val

func _on_lives(pid: int, val: int) -> void:
	var key := "lives%d" % pid
	if not _lbl.has(key):
		return
	var s := ""
	var i : int = 0
	while i < val:
		s += "♥  "
		i += 1
	var j : int = val
	while j < GameManager.MAX_LIVES:
		s += "♡  "
		j += 1
	_lbl[key].text = s.strip_edges()

func _on_parts(_pid: int, _val: int) -> void:
	_refresh_parts()

func _refresh_parts() -> void:
	var v : int = GameManager.get_parts(GameManager.current_player)
	if _lbl.has("parts_lbl"):
		_lbl["parts_lbl"].text = "piezas %d / %d" % [v, GameManager.PARTS_TO_UNLOCK_EXIT]

func _on_player(pid: int) -> void:
	if _lbl.has("player_lbl"):
		_lbl["player_lbl"].text = "▶  J%d ACTIVO" % (pid + 1)
		_lbl["player_lbl"].modulate = Color.YELLOW
		create_tween().tween_property(_lbl["player_lbl"], "modulate", Color.WHITE, 1.5)
	# Mostrar piezas del jugador que ahora está activo (independiente)
	_refresh_parts()

func _refresh_all() -> void:
	_on_score(0, GameManager.get_score(0))
	_on_score(1, GameManager.get_score(1))
	_on_lives(0, GameManager.get_lives(0))
	_on_lives(1, GameManager.get_lives(1))
	_refresh_parts()
	_on_player(GameManager.current_player)
	if _lbl.has("level_lbl"):
		_lbl["level_lbl"].text = "NIVEL %d" % GameManager.current_level
