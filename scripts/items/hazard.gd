## hazard.gd - Obstaculos industriales (vapor, chispas, barril)
extends Area2D

@export var hazard_type : int = 0

var _active : bool  = true
var _timer  : float = 0.0

func _ready() -> void:
	collision_layer = 16
	collision_mask  = 1

	var r  := RectangleShape2D.new()
	r.size = Vector2(28, 28)
	var cs := CollisionShape2D.new()
	cs.shape = r
	add_child(cs)

	var spr := Sprite2D.new()
	var tile_indices : Array[int] = [80, 96, 64]
	var tile_num : int = 0
	if hazard_type < tile_indices.size():
		tile_num = tile_indices[hazard_type]
	var tp : String = "res://assets/tiles/tile_%04d.png" % tile_num
	if ResourceLoader.exists(tp):
		spr.texture = load(tp)
		spr.scale   = Vector2(2.2, 2.2)
	else:
		var img := Image.create(28, 28, false, Image.FORMAT_RGBA8)
		var colors : Array[Color] = [Color(0.8, 0.8, 1.0), Color(1.0, 1.0, 0.2), Color(0.3, 0.8, 0.3)]
		var fill_c : Color = colors[0]
		if hazard_type < colors.size():
			fill_c = colors[hazard_type]
		img.fill(fill_c)
		spr.texture = ImageTexture.create_from_image(img)
	add_child(spr)

	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not _active:
		return
	if body.is_in_group("players") and body.has_method("take_damage"):
		body.take_damage()

func _process(delta: float) -> void:
	if hazard_type != 0:
		return
	_timer += delta
	if _timer > 1.4:
		_timer  = 0.0
		_active = !_active
		monitoring = _active
		visible    = _active
