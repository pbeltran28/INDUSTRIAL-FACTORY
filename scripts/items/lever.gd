## lever.gd - Palanca del puzzle (Nivel 3)
extends Area2D

signal activated

@export var lever_id : int = 0

var _done : bool = false

func _ready() -> void:
	add_to_group("levers")
	collision_layer = 0
	collision_mask  = 1

	var r  := RectangleShape2D.new()
	r.size = Vector2(28, 28)
	var cs := CollisionShape2D.new()
	cs.shape = r
	add_child(cs)

	var spr := Sprite2D.new()
	var tp  : String = "res://assets/tiles/tile_0048.png"
	if ResourceLoader.exists(tp):
		spr.texture = load(tp)
		spr.scale   = Vector2(2.5, 2.5)
	else:
		var img := Image.create(20, 20, false, Image.FORMAT_RGBA8)
		img.fill(Color(1.0, 0.3, 0.3))
		spr.texture = ImageTexture.create_from_image(img)
	add_child(spr)

	var lbl := Label.new()
	lbl.text     = "PALANCA %d" % lever_id
	lbl.position = Vector2(-45, -44)
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.7, 0.2))
	add_child(lbl)

	body_entered.connect(_on_body)

func _on_body(body: Node) -> void:
	if _done:
		return
	if not body.is_in_group("players"):
		return
	_done = true
	activated.emit()
	SoundManager.play_sfx("lever")
	GameManager.add_score(GameManager.current_player, 250)
