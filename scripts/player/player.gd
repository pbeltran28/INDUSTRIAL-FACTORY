## player.gd - CharacterBody2D (Guias 1,2,3)
extends CharacterBody2D

const SPEED    : float = 380.0
const JUMP_VEL : float = -860.0
const COYOTE   : float = 0.18
const DEATH_Y  : float = 800.0

@export var player_id : int = 0

var _gravity  : float = ProjectSettings.get_setting("physics/2d/default_gravity")
var _dead     : bool  = false
var _active   : bool  = false
var _coyote   : float = 0.0
var _inv      : float = 0.0
var _setup_done : bool = false

var _spr_idle : Texture2D = null
var _spr_run  : Texture2D = null
var _spr_jump : Texture2D = null
var _sprite   : Sprite2D  = null
var _anim_t   : float     = 0.0
var _anim_f   : int       = 0

## Llamar ANTES de add_child()
func setup(pid: int) -> void:
	player_id = pid
	add_to_group("players")

	# Capa 1 = jugador. Mascara: detecta solo plataformas (capa 3 = valor 4)
	# NO detecta enemigos (capa 2) — el daño lo maneja la hitbox del enemigo
	collision_layer = 1
	collision_mask  = 6   # Wall(4) + Enemy(2) — bloqueo fisico de ambos

	var rect := RectangleShape2D.new()
	rect.size = Vector2(24, 40)
	var cs := CollisionShape2D.new()
	cs.shape = rect
	add_child(cs)

	_sprite          = Sprite2D.new()
	_sprite.position = Vector2(0, -4)
	add_child(_sprite)

	var base := "res://assets/sprites/player%d_" % (pid + 1)
	if ResourceLoader.exists(base + "idle.png"): _spr_idle = load(base + "idle.png")
	if ResourceLoader.exists(base + "run.png"):  _spr_run  = load(base + "run.png")
	if ResourceLoader.exists(base + "jump.png"): _spr_jump = load(base + "jump.png")

	if _spr_idle == null:
		var img := Image.create(32, 48, false, Image.FORMAT_RGBA8)
		img.fill(Color(1.0, 0.5, 0.1) if pid == 0 else Color(0.3, 0.6, 1.0))
		_spr_idle = ImageTexture.create_from_image(img)
	if _spr_run  == null: _spr_run  = _spr_idle
	if _spr_jump == null: _spr_jump = _spr_idle

	_sprite.texture        = _spr_idle
	_sprite.region_enabled = true
	_sprite.region_rect    = Rect2(0, 0, 32, 48)

	_active     = (pid == GameManager.current_player)
	_setup_done = true

	GameManager.current_player_changed.connect(_on_player_changed)

func _physics_process(delta: float) -> void:
	if not _setup_done or _dead:
		return

	# Caida al vacío
	if global_position.y > DEATH_Y:
		take_damage()
		var sp := get_tree().get_first_node_in_group("spawn_point")
		global_position = sp.global_position if sp else Vector2(150, 540)
		velocity = Vector2.ZERO
		return

	if _inv > 0.0:
		_inv -= delta

	if not _active:
		velocity = Vector2.ZERO
		return

	if not is_on_floor():
		velocity.y += _gravity * delta
		_coyote     = max(0.0, _coyote - delta)
	else:
		_coyote = COYOTE

	var left_a  := "left_p%d"  % (player_id + 1)
	var right_a := "right_p%d" % (player_id + 1)
	var jump_a  := "jump_p%d"  % (player_id + 1)

	var dir : float = Input.get_axis(left_a, right_a)
	velocity.x = dir * SPEED if dir != 0.0 else move_toward(velocity.x, 0.0, 30.0)

	if Input.is_action_just_pressed(jump_a) and _coyote > 0.0:
		velocity.y = JUMP_VEL
		_coyote    = 0.0
		SoundManager.play_sfx("jump")

	move_and_slide()
	_update_sprite(delta, dir)

func _update_sprite(delta: float, dir: float) -> void:
	if _sprite == null: return
	_anim_t += delta
	if dir != 0.0: _sprite.flip_h = (dir < 0.0)

	if not is_on_floor():
		_sprite.texture = _spr_jump
		if _spr_jump: _sprite.region_rect = Rect2(0, 0, _spr_jump.get_width(), _spr_jump.get_height())
	elif abs(dir) > 0.1:
		if _anim_t > 0.07: _anim_t = 0.0; _anim_f = (_anim_f + 1) % 8
		_sprite.texture = _spr_run
		if _spr_run:
			var fw : int = _spr_run.get_width() / 8
			_sprite.region_rect = Rect2(_anim_f * fw, 0, fw, _spr_run.get_height())
	else:
		if _anim_t > 0.2: _anim_t = 0.0; _anim_f = (_anim_f + 1) % 4
		_sprite.texture = _spr_idle
		if _spr_idle:
			var fw2 : int = _spr_idle.get_width() / 4
			_sprite.region_rect = Rect2(_anim_f * fw2, 0, fw2, _spr_idle.get_height())

func take_damage() -> void:
	if _dead or _inv > 0.0: return
	_inv = 2.0
	GameManager.lose_life(player_id)
	if GameManager.get_lives(player_id) <= 0:
		_dead = true; visible = false; return
	_blink()

func _blink() -> void:
	var n : int = 0
	while n < 6:
		await get_tree().create_timer(0.18).timeout
		visible = !visible
		n += 1
	visible = true

func _on_player_changed(pid: int) -> void:
	_active = (player_id == pid)
	if not _active:
		velocity = Vector2.ZERO
		visible  = false   # P2 completamente invisible hasta su turno
	else:
		visible = true
