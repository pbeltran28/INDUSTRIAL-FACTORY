## robot.gd - Robot oxidado: patrulla + persigue + salta
extends CharacterBody2D

const SPEED_WALK  : float = 78.0
const SPEED_CHASE : float = 135.0
const GRAVITY     : float = 2500.0
const JUMP_V      : float = -780.0
const DETECT_DIST : float = 340.0   # distancia de deteccion en pixels

var _dir      : int   = 1
var _chasing  : bool  = false
var _jumps    : int   = 1
var _inv_dmg  : float = 0.0   # cooldown entre daños

var _ray_fwd  : RayCast2D   # pared adelante
var _ray_back : RayCast2D   # pared atras
var _ray_edge : RayCast2D   # borde de plataforma adelante
var _sprite   : Sprite2D
var _tex      : Texture2D
var _anim_t   : float = 0.0
var _anim_f   : int   = 0

func _ready() -> void:
	add_to_group("enemies")
	collision_layer = 2
	collision_mask  = 4   # solo Wall — NO colisiona con jugador ni otros enemigos

	var rect := RectangleShape2D.new()
	rect.size = Vector2(22, 28)
	var cs := CollisionShape2D.new()
	cs.shape = rect
	add_child(cs)

	_sprite = Sprite2D.new()
	_sprite.position = Vector2(0, -2)
	var tex_path := "res://assets/sprites/robot_run.png"
	if ResourceLoader.exists(tex_path):
		_tex = load(tex_path)
		_sprite.texture        = _tex
		_sprite.region_enabled = true
		_sprite.region_rect    = Rect2(0, 0, 28, 32)
	else:
		var img := Image.create(28, 32, false, Image.FORMAT_RGBA8)
		img.fill(Color(0.62, 0.46, 0.30))
		_sprite.texture = ImageTexture.create_from_image(img)
	add_child(_sprite)

	# RayCasts — se configuran en _ready, están activos desde el inicio
	_ray_fwd  = _mk_ray(Vector2( 30,  0))   # pared al frente
	_ray_back = _mk_ray(Vector2(-30,  0))   # pared detrás
	_ray_edge = _mk_ray(Vector2( 20, 36))   # suelo al frente (borde)

	# Hitbox de daño — Area2D separada del cuerpo físico
	var hit := Area2D.new()
	hit.collision_layer = 0
	hit.collision_mask  = 1
	var hs := CollisionShape2D.new()
	hs.shape = rect.duplicate()
	hit.add_child(hs)
	add_child(hit)
	hit.body_entered.connect(_on_hit)

func _mk_ray(target: Vector2) -> RayCast2D:
	var r := RayCast2D.new()
	r.target_position = target
	r.collision_mask  = 4
	r.enabled         = true
	add_child(r)
	return r

func _on_hit(body: Node) -> void:
	if body.is_in_group("players") and body.has_method("take_damage"):
		if _inv_dmg <= 0.0:
			body.take_damage()
			_inv_dmg = 1.5   # evitar daño múltiple por frame

func _physics_process(delta: float) -> void:
	if _inv_dmg > 0.0:
		_inv_dmg -= delta

	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		_jumps = 1

	# Detectar jugador por proximidad directa (no Area2D = más fiable)
	_chasing = false
	var players := get_tree().get_nodes_in_group("players")
	var closest_dist : float = DETECT_DIST + 1.0
	var closest_player : Node2D = null
	for p in players:
		if not is_instance_valid(p): continue
		if not p.visible: continue
		var d : float = global_position.distance_to(p.global_position)
		if d < closest_dist:
			closest_dist   = d
			closest_player = p

	if closest_player != null and closest_dist <= DETECT_DIST:
		_chasing = true
		var dx : float = closest_player.global_position.x - global_position.x
		_dir = (1 if dx > 0 else -1) as int
		velocity.x = SPEED_CHASE * _dir

		# Saltar si hay pared adelante o jugador está arriba
		var fwd_ray := _ray_fwd if _dir == 1 else _ray_back
		var player_above : bool = closest_player.global_position.y < global_position.y - 60
		if is_on_floor() and _jumps > 0 and (fwd_ray.is_colliding() or player_above):
			velocity.y = JUMP_V
			_jumps -= 1
	else:
		# Patrulla normal
		_ray_fwd.target_position  = Vector2(30 * _dir, 0)
		_ray_edge.target_position = Vector2(20 * _dir, 36)
		_ray_back.target_position = Vector2(-30 * _dir, 0)

		var hit_wall  : bool = _ray_fwd.is_colliding()
		var off_edge  : bool = is_on_floor() and not _ray_edge.is_colliding()

		if hit_wall or off_edge:
			_dir = -_dir
			_ray_fwd.target_position  = Vector2(30 * _dir, 0)
			_ray_edge.target_position = Vector2(20 * _dir, 36)

		velocity.x = SPEED_WALK * _dir

	move_and_slide()

	if _sprite:
		_sprite.flip_h = (_dir == -1)
		_anim_t += delta
		if _anim_t > 0.1 and _tex != null:
			_anim_t = 0.0
			_anim_f = (_anim_f + 1) % 4
			var fw : int = _tex.get_width() / 4
			_sprite.region_rect = Rect2(_anim_f * fw, 0, fw, _tex.get_height())

func die() -> void:
	var pid : int = GameManager.current_player
	GameManager.add_score(pid, GameManager.ENEMY_POINTS)
	GameManager.stats_enemies[pid] += 1
	queue_free()
