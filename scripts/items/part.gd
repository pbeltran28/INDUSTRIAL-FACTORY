## part.gd - Pieza metalica (tuerca hexagonal) o Engranaje Dorado
extends Area2D

@export var is_gear : bool = false

func _ready() -> void:
	add_to_group("mechanical_parts")
	collision_layer = 8
	collision_mask  = 1

	var c  := CircleShape2D.new()
	c.radius = 16.0
	var cs := CollisionShape2D.new()
	cs.shape = c
	add_child(cs)

	var spr := Sprite2D.new()
	# Usar las nuevas imágenes pixel-art
	var tex_path : String
	if is_gear:
		tex_path = "res://assets/sprites/golden_gear.png"
	else:
		tex_path = "res://assets/sprites/metal_part.png"

	if ResourceLoader.exists(tex_path):
		spr.texture = load(tex_path)
		spr.scale   = Vector2(1.4, 1.4)
	else:
		# Fallback
		var img := Image.create(20, 20, false, Image.FORMAT_RGBA8)
		img.fill(Color(1.0, 0.85, 0.1) if is_gear else Color(0.7, 0.7, 0.8))
		spr.texture = ImageTexture.create_from_image(img)
	add_child(spr)

	# Rotación continua — las piezas giran lentamente
	var rot_speed : float = 1.2 if is_gear else 0.6
	var rotate_tween := create_tween()
	rotate_tween.set_loops()
	rotate_tween.tween_property(spr, "rotation", TAU if is_gear else -TAU, 1.0 / rot_speed)

	# Flotación vertical suave
	var float_tween := create_tween()
	float_tween.set_loops()
	float_tween.tween_property(spr, "position:y", -8.0, 0.65).set_trans(Tween.TRANS_SINE)
	float_tween.tween_property(spr, "position:y",  0.0, 0.65).set_trans(Tween.TRANS_SINE)

	# Brillo pulsante para engranaje dorado
	if is_gear:
		var glow_tween := create_tween()
		glow_tween.set_loops()
		glow_tween.tween_property(spr, "modulate", Color(1.3, 1.2, 0.5, 1.0), 0.5)
		glow_tween.tween_property(spr, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)

	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("players"):
		return
	var pid : int = GameManager.current_player
	if body.get("player_id") != null:
		pid = body.player_id
	if is_gear:
		GameManager.add_gear(pid)
	else:
		GameManager.add_part(pid)
	# Efecto de recogida
	_pop()
	queue_free()

func _pop() -> void:
	var p := CPUParticles2D.new()
	p.emitting        = true
	p.one_shot        = true
	p.amount          = 12
	p.lifetime        = 0.5
	p.explosiveness   = 0.95
	p.initial_velocity_min = 60
	p.initial_velocity_max = 130
	p.color = Color(1.0, 0.85, 0.2) if is_gear else Color(0.75, 0.80, 0.90)
	get_parent().add_child(p)
	p.global_position = global_position
	get_tree().create_timer(0.8).timeout.connect(func(): if is_instance_valid(p): p.queue_free())
