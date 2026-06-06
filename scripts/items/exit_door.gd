## exit_door.gd - Puerta de salida del nivel
extends Area2D

var _locked : bool  = true
var _label  : Label = null

func _ready() -> void:
	add_to_group("exit_doors")
	collision_layer = 0
	collision_mask  = 1

	var r  := RectangleShape2D.new()
	r.size = Vector2(44, 64)
	var cs := CollisionShape2D.new()
	cs.shape = r
	add_child(cs)

	var i : int = 0
	while i < 3:
		var spr := Sprite2D.new()
		var tile_num : int = 16 + i * 2
		var tp : String = "res://assets/tiles/tile_%04d.png" % tile_num
		if ResourceLoader.exists(tp):
			spr.texture = load(tp)
			spr.scale   = Vector2(3.0, 3.0)
		else:
			var img := Image.create(18, 18, false, Image.FORMAT_RGBA8)
			img.fill(Color(0.5, 0.4, 0.2))
			spr.texture = ImageTexture.create_from_image(img)
		spr.position = Vector2(0, -54 + i * 28)
		add_child(spr)
		i += 1

	_label = Label.new()
	_label.text     = "BLOQUEADA: %d piezas" % GameManager.PARTS_TO_UNLOCK_EXIT
	_label.position = Vector2(-80, -95)
	_label.add_theme_font_size_override("font_size", 13)
	_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.5))
	add_child(_label)

	body_entered.connect(_on_body_entered)

	if GameManager.is_exit_unlocked():
		unlock()

func unlock() -> void:
	_locked = false
	if _label != null:
		_label.text = "SALIDA ABIERTA!"
		_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
	modulate = Color(1.0, 1.0, 1.0)
	SoundManager.play_sfx("unlock")

func _on_body_entered(body: Node2D) -> void:
	if _locked:
		return
	if body.is_in_group("players"):
		GameManager.complete_level()
