extends Control

var _time   : float = 0.0
var _gears  : Array = []
var _flicker: Label = null
var _fading : bool  = false
var _next   : String = ""

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()
	GameManager.reset_game()
	SoundManager.play_music("menu")
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.5)

func _build() -> void:
	# Fondo
	var bg_path := "res://assets/sprites/menu_bg.png"
	if ResourceLoader.exists(bg_path):
		var bg := TextureRect.new()
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		bg.texture      = load(bg_path)
		bg.stretch_mode = TextureRect.STRETCH_SCALE
		add_child(bg)
	var ov := ColorRect.new()
	ov.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ov.color = Color(0.0, 0.0, 0.0, 0.52)
	add_child(ov)

	# Pipes decorativos
	for yp in [0.0, 713.0]:
		var p := ColorRect.new()
		p.set_anchor(SIDE_LEFT, 0.0); p.set_anchor(SIDE_RIGHT, 1.0)
		p.offset_top = yp; p.offset_bottom = yp + 7
		p.color = Color(0.48, 0.38, 0.18)
		add_child(p)

	# Divisor vertical
	var div := ColorRect.new()
	div.offset_left = 548; div.offset_right = 555
	div.offset_top  = 7;   div.offset_bottom = 713
	div.color = Color(0.4, 0.32, 0.16, 0.9)
	add_child(div)

	# Engranajes decorativos
	for gd in [
		[50,  50,  130, Color(1.0, 0.55, 0.08, 0.20)],
		[1085,455, 185, Color(1.0, 0.45, 0.06, 0.14)],
		[918, 18,   88, Color(1.0, 0.65, 0.18, 0.17)],
		[8,   515, 105, Color(1.0, 0.50, 0.10, 0.17)],
	]:
		var g := Label.new()
		g.text = "⚙"
		g.position = Vector2(gd[0], gd[1])
		g.add_theme_font_size_override("font_size", gd[2])
		g.add_theme_color_override("font_color", gd[3])
		add_child(g)
		_gears.append(g)

	# ── COLUMNA IZQUIERDA ──────────────────────────────────────────
	# ZONA INDUSTRIAL — negrita visual con sombra
	var warn_bg := ColorRect.new()
	warn_bg.offset_left = 20; warn_bg.offset_right = 528
	warn_bg.offset_top  = 12; warn_bg.offset_bottom = 32
	warn_bg.color = Color(0.9, 0.65, 0.05, 0.12)
	add_child(warn_bg)
	_lbl("⚠  ZONA INDUSTRIAL RESTRINGIDA  ⚠", 20, 14, 528, 13,
		Color(1.0, 0.85, 0.05), HORIZONTAL_ALIGNMENT_CENTER)

	# Título grande
	_lbl("INDUSTRIAL", 20, 38, 528, 72,
		Color(1.0, 0.66, 0.07), HORIZONTAL_ALIGNMENT_CENTER)
	_lbl("FACTORY",    20, 110, 528, 72,
		Color(0.88, 0.50, 0.06), HORIZONTAL_ALIGNMENT_CENTER)

	_lbl("La fábrica abandonada te espera...", 20, 194, 528, 15,
		Color(0.62, 0.62, 0.68), HORIZONTAL_ALIGNMENT_CENTER)

	# Separador naranja
	var sep := ColorRect.new()
	sep.offset_left = 60;  sep.offset_right  = 488
	sep.offset_top  = 218; sep.offset_bottom = 222
	sep.color = Color(0.9, 0.48, 0.05)
	add_child(sep)

	# Badges — DEBAJO del separador, sin montarse con el título
	var badge_y : float = 228.0
	for bd in [
		["3 NIVELES",   Color(0.2, 0.9, 0.45),  60],
		["2 JUGADORES", Color(0.35, 0.75, 1.0), 195],
		["PIXEL ART",   Color(1.0, 0.7,  0.3),  340],
	]:
		var bb := ColorRect.new()
		bb.offset_left   = bd[2];           bb.offset_right  = bd[2] + 118
		bb.offset_top    = badge_y;         bb.offset_bottom = badge_y + 26
		bb.color = Color(bd[1].r * 0.14, bd[1].g * 0.14, bd[1].b * 0.14, 0.9)
		add_child(bb)
		var bln := ColorRect.new()
		bln.offset_left  = bd[2];  bln.offset_right  = bd[2] + 118
		bln.offset_top   = badge_y; bln.offset_bottom = badge_y + 3
		bln.color = Color(bd[1].r, bd[1].g, bd[1].b, 0.8)
		add_child(bln)
		_lbl(bd[0], bd[2]+2, badge_y+6, bd[2]+116, 12, bd[1], HORIZONTAL_ALIGNMENT_CENTER)

	# ── CONTROLES en cajas separadas ──
	var ctrl_y : float = 264.0

	# Caja J1
	var b1 := ColorRect.new()
	b1.offset_left = 22; b1.offset_right  = 264
	b1.offset_top  = ctrl_y; b1.offset_bottom = ctrl_y + 110
	b1.color = Color(1.0, 0.55, 0.05, 0.08)
	add_child(b1)
	var b1t := ColorRect.new()
	b1t.offset_left = 22; b1t.offset_right = 264
	b1t.offset_top  = ctrl_y; b1t.offset_bottom = ctrl_y + 3
	b1t.color = Color(1.0, 0.55, 0.05, 0.85)
	add_child(b1t)
	_lbl("JUGADOR 1",        28, ctrl_y+7,  258, 14, Color(1.0, 0.65, 0.1), HORIZONTAL_ALIGNMENT_CENTER)
	_lbl("A / D  →  mover",  30, ctrl_y+28, 258, 13, Color(0.92, 0.92, 0.92))
	_lbl("W      →  saltar", 30, ctrl_y+46, 258, 13, Color(0.92, 0.92, 0.92))
	_lbl("H  →  Guardar",    30, ctrl_y+64, 258, 12, Color(0.72, 0.72, 0.78))
	_lbl("J  →  Cargar",     30, ctrl_y+80, 258, 12, Color(0.72, 0.72, 0.78))

	# Caja J2
	var b2 := ColorRect.new()
	b2.offset_left = 276; b2.offset_right  = 526
	b2.offset_top  = ctrl_y; b2.offset_bottom = ctrl_y + 110
	b2.color = Color(0.3, 0.6, 1.0, 0.08)
	add_child(b2)
	var b2t := ColorRect.new()
	b2t.offset_left = 276; b2t.offset_right = 526
	b2t.offset_top  = ctrl_y; b2t.offset_bottom = ctrl_y + 3
	b2t.color = Color(0.35, 0.72, 1.0, 0.85)
	add_child(b2t)
	_lbl("JUGADOR 2",           282, ctrl_y+7,  520, 14, Color(0.4, 0.78, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	_lbl("← / →  →  mover",   284, ctrl_y+28, 520, 13, Color(0.92, 0.92, 0.92))
	_lbl("↑       →  saltar",  284, ctrl_y+46, 520, 13, Color(0.92, 0.92, 0.92))
	_lbl("(mismas teclas H/J)", 284, ctrl_y+68, 520, 12, Color(0.62, 0.62, 0.68))

	_lbl("Coyote Time activo: 0.18s tras caer del borde",
		22, ctrl_y+118, 526, 11, Color(0.52, 0.52, 0.58), HORIZONTAL_ALIGNMENT_CENTER)

	# ── COLUMNA DERECHA: BOTONES ──────────────────────────────────
	_lbl("[ PANEL DE CONTROL ]", 560, 60, 1260, 17,
		Color(0.4, 0.82, 0.48, 0.9), HORIZONTAL_ALIGNMENT_CENTER)

	var btns := [
		["▶   INICIAR MISIÓN",  "_on_start",  Color(0.95, 0.58, 0.05), 100, 22],
		["⏯   CONTINUAR",       "_on_cont",   Color(0.38, 0.80, 1.0),  188, 18],
		["📖  TUTORIAL",          "_on_tut",    Color(0.55, 0.88, 0.55), 262, 18],
		["✖   SALIR",             "_on_quit",   Color(0.82, 0.32, 0.32), 336, 18],
	]
	for i in btns.size():
		var bd    : Array = btns[i]
		var c     : Color = bd[2]
		var top   : float = float(bd[3])
		var bg := ColorRect.new()
		bg.offset_left  = 575; bg.offset_right  = 1245
		bg.offset_top   = top; bg.offset_bottom = top + 62
		bg.color = Color(c.r * 0.12, c.g * 0.12, c.b * 0.12, 0.9)
		add_child(bg)
		var btn := Button.new()
		btn.text = bd[0]
		btn.offset_left  = 575; btn.offset_right  = 1245
		btn.offset_top   = top; btn.offset_bottom = top + 62
		btn.add_theme_font_size_override("font_size", bd[4])
		btn.add_theme_color_override("font_color", c)
		btn.modulate.a = 0.0
		add_child(btn)
		btn.pressed.connect(Callable(self, bd[1]))
		var tw  := create_tween(); tw.tween_interval(0.07 * i + 0.25)
		tw.tween_property(btn, "modulate:a", 1.0, 0.35)
		var tw2 := create_tween(); tw2.tween_interval(0.07 * i + 0.25)
		tw2.tween_property(bg, "modulate:a", 1.0, 0.35)

	# "Introduce moneda" — debajo de SALIR, más grande y llamativo
	var coin_bg := ColorRect.new()
	coin_bg.offset_left  = 575; coin_bg.offset_right = 1245
	coin_bg.offset_top   = 414; coin_bg.offset_bottom = 450
	coin_bg.color = Color(0.9, 0.8, 0.1, 0.08)
	add_child(coin_bg)
	_flicker = Label.new()
	_flicker.text = "★   INTRODUCE MONEDA PARA CONTINUAR   ★"
	_flicker.offset_left  = 575; _flicker.offset_right = 1245
	_flicker.offset_top   = 418
	_flicker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_flicker.add_theme_font_size_override("font_size", 15)
	_flicker.add_theme_color_override("font_color", Color(1.0, 0.92, 0.18))
	add_child(_flicker)

	_lbl("Godot 4.6  ·  Industrial Factory  ·  v1.0",
		560, 688, 1260, 11, Color(0.33, 0.33, 0.33), HORIZONTAL_ALIGNMENT_CENTER)

func _lbl(text: String, lx: float, ly: float, rx: float, fs: int,
		color: Color, align: int = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var l := Label.new()
	l.text = text; l.offset_left = lx; l.offset_top = ly; l.offset_right = rx
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = align
	add_child(l); return l

func _process(delta: float) -> void:
	_time += delta
	if _flicker:
		_flicker.modulate.a = 0.55 + 0.45 * sin(_time * 3.8)
	for i in _gears.size():
		_gears[i].rotation += delta * (0.32 if i % 2 == 0 else -0.20)
	if _fading:
		modulate.a = max(0.0, modulate.a - delta * 3.0)
		if modulate.a <= 0.0:
			get_tree().change_scene_to_file(_next)

func _go(path: String) -> void: _fading = true; _next = path
func _on_start() -> void: GameManager.reset_game(); _go("res://scenes/nivel1.tscn")
func _on_cont()  -> void:
	if SaveManager.load_game(): _go("res://scenes/nivel%d.tscn" % GameManager.current_level)
func _on_tut()   -> void: _go("res://scenes/tutorial.tscn")
func _on_quit()  -> void: get_tree().quit()
