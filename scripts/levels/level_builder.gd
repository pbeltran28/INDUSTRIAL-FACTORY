## level_builder.gd — Construye TODO el nivel en codigo GDScript puro.
extends Node2D

@export var level_number : int = 1

var _PlayerScript : Script = null
var _RobotScript  : Script = null
var _DroneScript  : Script = null
var _PartScript   : Script = null
var _HazardScript : Script = null
var _ExitScript   : Script = null
var _LeverScript  : Script = null
var _HudScript    : Script = null

const TS         : int     = 54
const TILE_SCALE : Vector2 = Vector2(3.0, 3.0)

var _cam         : Camera2D = null
var _players     : Array    = []
var _levers_done : int      = 0
var _levers_req  : int      = 0

const LEVELS := {
	1: {
		# FACIL: 10 piezas + 2 engranajes. Robots mas lentos.
		# Piezas dispersas: inicio/medio/final y flotando
		"world_w"  : 3200,
		"spawn1"   : [120, 540],
		"spawn2"   : [170, 540],
		"platforms": [
			[0,600,56],[440,500,5],[750,420,5],[1080,340,6],
			[1420,280,5],[1760,380,6],[2100,300,5],[2450,220,5],
		],
		"robots" : [[700,540],[1400,540],[2100,540]],
		"drones" : [],
		# 10 piezas: algunas en plataformas, algunas flotando, 3 al final cerca de enemigos
		"parts"  : [
			[300, 470],   # inicio facil
			[470, 462],   # plataforma 1
			[790, 382],   # plataforma 2
			[900, 340],   # flotando sobre plataforma 2
			[1120,302],   # plataforma 3
			[1300,250],   # flotando (saltar para llegar)
			[1460,242],   # plataforma 4
			[1800,342],   # plataforma 5 - zona enemigos
			[2000,430],   # final - nivel piso, cerca de robot
			[2250,400],   # final derecha - zona de peligro
		],
		"gears"  : [
			[1080,155],   # secreto: encima de plataforma 3 (saltar mucho)
			[2450,140],   # secreto: esquina superior derecha
		],
		"hazards": [
			[950,572,0],[1650,572,0],
			[1200,572,1],
			[1800,572,2],
		],
		"levers" : [],
		"exit"   : [2510,175],
	},
	2: {
		# INTERMEDIO: 10 piezas + 2 engranajes. 1 robot + 1 drone.
		"world_w"  : 3800,
		"spawn1"   : [120, 540],
		"spawn2"   : [170, 540],
		"platforms": [
			[0,600,68],[400,500,5],[720,410,5],[1060,330,6],
			[1380,440,5],[1720,340,6],[2060,260,5],[2400,360,6],[2750,280,5],
		],
		"robots" : [[800,540]],
		"drones" : [[1900,540]],
		"parts"  : [
			[280, 470],
			[440, 462],
			[760, 372],
			[870, 310],   # flotando
			[1100,292],
			[1250,210],   # flotando alto
			[1420,402],
			[1760,302],
			[2100,220],
			[2500,340],   # zona enemigos final
		],
		"gears"  : [
			[1060,150],
			[2390,170],
		],
		"hazards": [
			[600,572,0],[1300,572,0],[2100,572,0],
			[950,315,1],[1900,315,1],
			[1500,572,2],[2500,572,2],
		],
		"levers" : [],
		"exit"   : [2850,242],
	},
	3: {
		# DIFICIL: 10 piezas + 3 engranajes. 2 robots + 2 drones.
		"world_w"  : 4200,
		"spawn1"   : [120, 540],
		"spawn2"   : [170, 540],
		"platforms": [
			[0,600,74],[380,490,5],[700,410,5],[1020,330,6],
			[1360,440,5],[1700,350,6],[2040,270,5],[2380,380,6],
			[2700,290,5],[2950,380,7],
		],
		"robots" : [[650,540],[1900,540]],
		"drones" : [[1300,540],[2600,540]],
		"parts"  : [
			[240, 475],
			[420, 452],
			[740, 372],
			[850, 290],   # flotando
			[1060,292],
			[1200,210],   # flotando alto
			[1400,402],
			[1740,312],
			[2200,450],   # zona enemigos
			[2700,360],   # final peligroso
		],
		"gears"  : [
			[700,170],
			[1700,160],
			[2700,90],    # muy secreto, arriba a la derecha
		],
		"hazards": [
			[500,572,0],[900,572,0],[1500,572,0],[2200,572,0],[3000,572,0],
			[700,315,1],[1200,315,1],[2000,332,1],[2800,272,1],
			[1050,572,2],[1800,572,2],[2500,572,2],[3200,572,2],
		],
		"levers" : [[740,375,1],[1400,408,2],[2040,240,3]],
		"exit"   : [3000,345],
	}
}

func _ready() -> void:
	_PlayerScript = load("res://scripts/player/player.gd")
	_RobotScript  = load("res://scripts/enemies/robot.gd")
	_DroneScript  = load("res://scripts/enemies/drone.gd")
	_PartScript   = load("res://scripts/items/part.gd")
	_HazardScript = load("res://scripts/items/hazard.gd")
	_ExitScript   = load("res://scripts/items/exit_door.gd")
	_LeverScript  = load("res://scripts/items/lever.gd")
	_HudScript    = load("res://scripts/ui/hud.gd")

	GameManager.current_level = level_number
	# Resetear piezas del jugador activo → el nivel recien cargo, empieza en 0
	var _pid : int = GameManager.current_player
	GameManager.player_parts[_pid] = 0
	GameManager.parts_changed.emit(_pid, 0)
	SoundManager.play_music("level%d" % level_number)

	var data : Dictionary = LEVELS.get(level_number, LEVELS[1])
	_build_background(data["world_w"])
	_build_platforms(data["platforms"])
	_build_walls(data["world_w"])
	_spawn_players(data["spawn1"], data["spawn2"])
	_build_parts(data["parts"], data["gears"])
	_build_hazards(data["hazards"])
	_build_robots(data["robots"])
	_build_drones(data.get("drones", []))
	_build_levers(data.get("levers", []))
	_build_exit(data["exit"])
	_build_hud()

	if GameManager.is_exit_unlocked():
		get_tree().call_group("exit_doors", "unlock")

	GameManager.current_player_changed.connect(_on_player_changed)

func _build_background(world_w: int) -> void:
	var bg := ColorRect.new()
	bg.offset_left   = -500
	bg.offset_top    = -400
	bg.offset_right  = world_w + 500
	bg.offset_bottom = 900
	bg.color         = Color(0.07, 0.07, 0.12)
	bg.z_index       = -10
	add_child(bg)

	var tile_cols : Array[int] = [2, 3, 6, 10]
	var num_cols  : int        = tile_cols.size()
	var tx : int = 0
	while tx < world_w:
		var ty : int = 0
		while ty < 600:
			var idx : int = (tx / TS + ty / TS) % num_cols
			var col : int = tile_cols[idx]
			var spr : Sprite2D = _make_tile(col, 3, TILE_SCALE * 0.7)
			spr.modulate = Color(1.0, 1.0, 1.0, 0.07)
			spr.position = Vector2(tx, ty)
			spr.z_index  = -9
			add_child(spr)
			ty += TS * 2
		tx += TS * 2

func _build_platforms(platforms: Array) -> void:
	for pd in platforms:
		var px : float = float(pd[0])
		var py : float = float(pd[1])
		var n  : int   = int(pd[2])

		var body := StaticBody2D.new()
		body.collision_layer = 4
		body.collision_mask  = 0
		body.position = Vector2(px + n * TS * 0.5 - TS * 0.5, py)
		add_child(body)

		var cs   := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(n * TS, TS)
		cs.shape  = rect
		body.add_child(cs)

		for i in range(n):
			var tile_col : int = 1
			if i == 0:     tile_col = 0
			elif i == n-1: tile_col = 2
			var spr : Sprite2D = _make_tile(tile_col, 0, TILE_SCALE)
			spr.position = Vector2(i * TS - (n - 1) * TS * 0.5, 0)
			body.add_child(spr)

func _build_walls(world_w: int) -> void:
	for xpos in [0, world_w]:
		var wall := StaticBody2D.new()
		wall.collision_layer = 4
		wall.collision_mask  = 0
		wall.position = Vector2(xpos, 300)
		var cs := CollisionShape2D.new()
		var r  := RectangleShape2D.new()
		r.size   = Vector2(20, 1200)
		cs.shape = r
		wall.add_child(cs)
		add_child(wall)

func _spawn_players(sp1: Array, sp2: Array) -> void:
	if _PlayerScript == null:
		return
	for i in range(2):
		var p := CharacterBody2D.new()
		p.set_script(_PlayerScript)
		p.setup(i)
		var spawn_pos : Vector2 = Vector2(float(sp1[0]), float(sp1[1])) if i == 0 \
								else Vector2(float(sp2[0]), float(sp2[1]))
		p.global_position = spawn_pos
		# P2 invisible hasta que P1 pierda todas las vidas
		p.visible = (i == GameManager.current_player)
		add_child(p)
		_players.append(p)
		if i == 0:
			p.add_to_group("spawn_point")
	_attach_camera()

func _attach_camera() -> void:
	if _cam == null:
		_cam = Camera2D.new()
		_cam.zoom                       = Vector2(1.5, 1.5)
		_cam.position_smoothing_enabled = true
		_cam.position_smoothing_speed   = 7.0
		_cam.limit_left                 = 0
		_cam.limit_bottom               = 700

	var pid : int = GameManager.current_player
	if pid < _players.size() and is_instance_valid(_players[pid]):
		var target : Node = _players[pid]
		if _cam.get_parent() != null:
			_cam.reparent(target)
		else:
			target.add_child(_cam)
		_cam.position = Vector2.ZERO

func _on_player_changed(pid: int) -> void:
	for i in _players.size():
		if is_instance_valid(_players[i]):
			_players[i].visible = (i == pid)
	_attach_camera()

func _build_parts(parts: Array, gears: Array) -> void:
	if _PartScript == null:
		return
	for pd in parts:
		var a := Area2D.new()
		a.set_script(_PartScript)
		a.is_gear  = false
		a.position = Vector2(float(pd[0]), float(pd[1]))
		add_child(a)
	for gd in gears:
		var a := Area2D.new()
		a.set_script(_PartScript)
		a.is_gear  = true
		a.position = Vector2(float(gd[0]), float(gd[1]))
		add_child(a)

func _build_hazards(hazards: Array) -> void:
	if _HazardScript == null:
		return
	for hd in hazards:
		var a := Area2D.new()
		a.set_script(_HazardScript)
		a.hazard_type = int(hd[2])
		a.position    = Vector2(float(hd[0]), float(hd[1]))
		add_child(a)

func _build_robots(robots: Array) -> void:
	if _RobotScript == null:
		return
	for rd in robots:
		var e := CharacterBody2D.new()
		e.set_script(_RobotScript)
		e.position = Vector2(float(rd[0]), float(rd[1]))
		add_child(e)

func _build_drones(drones: Array) -> void:
	if _DroneScript == null:
		return
	for dd in drones:
		var e := CharacterBody2D.new()
		e.set_script(_DroneScript)
		e.position = Vector2(float(dd[0]), float(dd[1]))
		add_child(e)

func _build_levers(levers: Array) -> void:
	if levers.is_empty() or _LeverScript == null:
		return
	_levers_req = levers.size()

	var gen_lbl := Label.new()
	gen_lbl.text     = "GENERADOR: 0 / %d" % _levers_req
	gen_lbl.position = Vector2(2950, 268)
	gen_lbl.add_theme_font_size_override("font_size", 16)
	gen_lbl.add_theme_color_override("font_color", Color(1.0, 0.6, 0.2))
	add_child(gen_lbl)

	var gen_rect := ColorRect.new()
	gen_rect.position = Vector2(2930, 292)
	gen_rect.size     = Vector2(80, 80)
	gen_rect.color    = Color(0.5, 0.3, 0.3)
	add_child(gen_rect)

	for ld in levers:
		var a := Area2D.new()
		a.set_script(_LeverScript)
		a.lever_id = int(ld[2])
		a.position = Vector2(float(ld[0]), float(ld[1]))
		add_child(a)
		var lbl_ref  : Label     = gen_lbl
		var rect_ref : ColorRect = gen_rect
		a.activated.connect(func() -> void:
			_levers_done += 1
			lbl_ref.text = "GENERADOR: %d / %d" % [_levers_done, _levers_req]
			if _levers_done >= _levers_req:
				rect_ref.color = Color(0.3, 1.0, 0.4)
				lbl_ref.text   = "GENERADOR REPARADO"
				get_tree().call_group("exit_doors", "unlock")
				GameManager.add_score(GameManager.current_player, 1000)
				SoundManager.play_sfx("unlock")
		)

func _build_exit(exit_pos: Array) -> void:
	if _ExitScript == null:
		return
	var a := Area2D.new()
	a.set_script(_ExitScript)
	a.position = Vector2(float(exit_pos[0]), float(exit_pos[1]))
	add_child(a)

func _build_hud() -> void:
	if _HudScript == null:
		return
	var hud := CanvasLayer.new()
	hud.set_script(_HudScript)
	add_child(hud)

func _make_tile(col: int, row: int, scale: Vector2) -> Sprite2D:
	var spr  := Sprite2D.new()
	var idx  : int    = row * 16 + col
	var path : String = "res://assets/tiles/tile_%04d.png" % idx
	if ResourceLoader.exists(path):
		spr.texture = load(path)
	else:
		var img := Image.create(18, 18, false, Image.FORMAT_RGBA8)
		img.fill(Color(0.42, 0.35, 0.22))
		spr.texture = ImageTexture.create_from_image(img)
	spr.scale = scale
	return spr
