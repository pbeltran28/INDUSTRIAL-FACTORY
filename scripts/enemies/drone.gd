## drone.gd - Drone industrial: patrulla + persigue + salta
extends CharacterBody2D

const SPEED_WALK  : float = 65.0
const SPEED_CHASE : float = 150.0
const GRAVITY     : float = 2500.0
const JUMP_V      : float = -820.0
const DETECT_DIST : float = 340.0

var _dir     : int   = -1   # empieza yendo a la izquierda (diferente al robot)
var _chasing : bool  = false
var _jumps   : int   = 1
var _inv_dmg : float = 0.0

var _ray_fwd  : RayCast2D
var _ray_back : RayCast2D
var _ray_edge : RayCast2D
var _sprite   : Sprite2D
var _anim_t   : float = 0.0

func _ready() -> void:
	add_to_group("enemies")
	collision_layer = 2
	collision_mask  = 4   # solo Wall

	var rect := RectangleShape2D.new()
	rect.size = Vector2(22, 22)
	var cs := CollisionShape2D.new()
	cs.shape = rect
	add_child(cs)

	_sprite = Sprite2D.new()
	var tex_path := "res://assets/sprites/drone.png"
	if ResourceLoader.exists(tex_path):
		_sprite.texture = load(tex_path)
	else:
		var img := Image.create(30, 20, false, Image.FORMAT_RGBA8)
		img.fill(Color(0.25, 0.45, 0.85))
		_sprite.texture = ImageTexture.create_from_image(img)
	add_child(_sprite)

	_ray_fwd  = _mk_ray(Vector2( 30,  0))
	_ray_back = _mk_ray(Vector2(-30,  0))
	_ray_edge = _mk_ray(Vector2( 20, 30))

	# Hitbox de daño
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
			_inv_dmg = 1.5

func _physics_process(delta: float) -> void:
	if _inv_dmg > 0.0:
		_inv_dmg -= delta

	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		_jumps = 1

	# Detectar jugador visible más cercano
	_chasing = false
	var players := get_tree().get_nodes_in_group("players")
	var closest_dist   : float  = DETECT_DIST + 1.0
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

		var fwd_ray      := _ray_fwd if _dir == 1 else _ray_back
		var player_above : bool = closest_player.global_position.y < global_position.y - 55
		if is_on_floor() and _jumps > 0 and (fwd_ray.is_colliding() or player_above):
			velocity.y = JUMP_V
			_jumps -= 1
	else:
		_ray_fwd.target_position  = Vector2(30 * _dir, 0)
		_ray_edge.target_position = Vector2(20 * _dir, 30)
		_ray_back.target_position = Vector2(-30 * _dir, 0)

		var hit_wall : bool = _ray_fwd.is_colliding()
		var off_edge : bool = is_on_floor() and not _ray_edge.is_colliding()

		if hit_wall or off_edge:
			_dir = -_dir
			_ray_fwd.target_position  = Vector2(30 * _dir, 0)
			_ray_edge.target_position = Vector2(20 * _dir, 30)

		velocity.x = SPEED_WALK * _dir

	move_and_slide()

	if _sprite:
		_sprite.flip_h = (_dir == -1)

func die() -> void:
	var pid : int = GameManager.current_player
	GameManager.add_score(pid, GameManager.ENEMY_POINTS)
	GameManager.stats_enemies[pid] += 1
	queue_free()
