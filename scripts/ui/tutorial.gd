## tutorial.gd - Manual de Operario con boton de regreso
extends Control

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.4)

func _build() -> void:
	var bg_p := "res://assets/sprites/menu_bg.png"
	if ResourceLoader.exists(bg_p):
		var bg := TextureRect.new()
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		bg.texture = load(bg_p); bg.stretch_mode = TextureRect.STRETCH_SCALE
		add_child(bg)
	var ov := ColorRect.new()
	ov.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ov.color = Color(0.0, 0.0, 0.0, 0.72)
	add_child(ov)

	# Título con engranajes decorativos
	_lbl_c("⚙   MANUAL DE OPERARIO   ⚙", 30, 38, Color(1.0, 0.75, 0.14))

	var sep := ColorRect.new()
	sep.set_anchor(SIDE_LEFT, 0.0); sep.set_anchor(SIDE_RIGHT, 1.0)
	sep.offset_top = 78; sep.offset_bottom = 81
	sep.offset_left = 40; sep.offset_right = -40
	sep.color = Color(0.55, 0.4, 0.15)
	add_child(sep)

	# Contenido scrollable
	var rtl := RichTextLabel.new()
	rtl.bbcode_enabled = true
	rtl.fit_content    = false
	rtl.set_anchor(SIDE_LEFT,   0.0); rtl.set_anchor(SIDE_RIGHT,  1.0)
	rtl.set_anchor(SIDE_TOP,    0.0); rtl.set_anchor(SIDE_BOTTOM, 1.0)
	rtl.offset_top    = 90
	rtl.offset_bottom = -72
	rtl.offset_left   = 48
	rtl.offset_right  = -48
	rtl.add_theme_font_size_override("normal_font_size", 15)
	rtl.text = """
[b][color=#ffd84d]OBJETIVO[/color][/b]
Recolecta [color=#ffd84d]⚙ piezas mecánicas[/color] para desbloquear la salida de cada nivel. Los [color=#ffdd22]engranajes dorados[/color] escondidos en zonas secretas otorgan +500 pts.

[b][color=#7ecfff]CONTROLES[/color][/b]
  [color=#ffaa44]Jugador 1 (WASD):[/color]  A/D = mover  |  W = saltar  (Coyote Time 0.18s)
  [color=#88aaff]Jugador 2 (Flechas):[/color]  ← / → = mover  |  ↑ = saltar
  [color=#ffcc88]H[/color] = Guardar partida     [color=#ffcc88]J[/color] = Cargar partida

[b][color=#ff7777]PELIGROS[/color][/b]
  [color=#aaccff]💨 Vapor caliente[/color] — intermitente, espera a que se apague antes de pasar
  [color=#ffff88]⚡ Chispas eléctricas[/color] — daño instantáneo, evítalas siempre
  [color=#99ff88]🛢 Barriles tóxicos[/color] — sáltalos por encima

[b][color=#ff9944]ENEMIGOS[/color][/b]
  [color=#ffcc88]🤖 Robot oxidado[/color] — patrulla de lado a lado con RayCast2D (Guía 11), se devuelve al borde
  [color=#88ccff]🛸 Drone industrial[/color] — te detecta a 280px y persigue activamente (Guía 12)

[b][color=#aaffaa]NIVELES[/color][/b]
  [color=#88ff88]Nivel 1 — FÁCIL:[/color] plataformas simples, pocos enemigos, introducción a mecánicas
  [color=#ffdd44]Nivel 2 — INTERMEDIO:[/color] más plataformas, drones, más peligros activos
  [color=#ff6644]Nivel 3 — DIFÍCIL:[/color] activa las 3 palancas para reparar el generador central

[b][color=#ccaaff]2 JUGADORES[/color][/b]
Cuando un jugador pierde todas sus [color=#ff5555]♥[/color] vidas, el turno pasa al otro.
El juego termina (Game Over) cuando ambos jugadores se quedan sin vidas.

[b][color=#ffd84d]PUNTUACIÓN[/color][/b]
  Pieza mecánica = +100 pts  |  Engranaje dorado = +500 pts
  Enemigo eliminado = +200 pts  |  Palanca activada = +250 pts
  Generador reparado = +1000 pts
"""
	add_child(rtl)

	# Botón de regreso prominente en la parte inferior
	var btn_bg := ColorRect.new()
	btn_bg.set_anchor(SIDE_LEFT, 0.5); btn_bg.set_anchor(SIDE_RIGHT, 0.5)
	btn_bg.set_anchor(SIDE_BOTTOM, 1.0); btn_bg.set_anchor(SIDE_TOP, 1.0)
	btn_bg.offset_left = -185; btn_bg.offset_right  = 185
	btn_bg.offset_top  = -66;  btn_bg.offset_bottom = -8
	btn_bg.color = Color(0.55, 0.88, 0.55, 0.12)
	add_child(btn_bg)

	var btn := Button.new()
	btn.text = "◄   VOLVER AL MENÚ PRINCIPAL"
	btn.set_anchor(SIDE_LEFT, 0.5); btn.set_anchor(SIDE_RIGHT, 0.5)
	btn.set_anchor(SIDE_BOTTOM, 1.0); btn.set_anchor(SIDE_TOP, 1.0)
	btn.offset_left = -185; btn.offset_right  = 185
	btn.offset_top  = -66;  btn.offset_bottom = -8
	btn.add_theme_font_size_override("font_size", 18)
	btn.add_theme_color_override("font_color", Color(0.55, 0.92, 0.58))
	btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
	add_child(btn)

func _lbl_c(text: String, cy: float, fs: int, color: Color) -> void:
	var l := Label.new()
	l.text = text
	l.set_anchor(SIDE_LEFT,  0.0); l.set_anchor(SIDE_RIGHT, 1.0)
	l.offset_top = cy
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", color)
	add_child(l)
