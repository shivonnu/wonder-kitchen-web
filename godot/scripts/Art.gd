class_name Art
extends Object

const NAVY := Color("0b1026")
const INDIGO := Color("1b2450")
const GOLD := Color("e7c56a")
const CREAM := Color("f4efe4")
const SALT := Color("d9e7ff")

static var chroma: ShaderMaterial
static var font: Font

static func boot() -> void:
	if chroma == null:
		chroma = ShaderMaterial.new()
		chroma.shader = load("res://shaders/chroma_key.gdshader")
	if font == null:
		font = load("res://assets/fonts/ZenMaruGothic-Medium.ttf")


static func fill_pct(node: Control, x: float, y: float, w: float, h: float) -> void:
	node.layout_mode = 1
	node.anchor_left = x / 100.0
	node.anchor_top = y / 100.0
	node.anchor_right = (x + w) / 100.0
	node.anchor_bottom = (y + h) / 100.0
	node.offset_left = 0.0
	node.offset_top = 0.0
	node.offset_right = 0.0
	node.offset_bottom = 0.0


static func sprite(parent: Control, path: String, x: float, y: float, w: float, h: float, crop_half := false, bob := false, bob_half := 1.25, crop_right := false) -> TextureRect:
	boot()
	var r := TextureRect.new()
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	r.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	r.material = chroma
	var tex: Texture2D = load(path)
	if crop_half and tex:
		var atlas := AtlasTexture.new()
		atlas.atlas = tex
		var hw := tex.get_width() * 0.5
		atlas.region = Rect2(hw if crop_right else 0.0, 0, hw, tex.get_height())
		r.texture = atlas
	else:
		r.texture = tex
	fill_pct(r, x, y, w, h)
	parent.add_child(r)
	if bob:
		_bob(r, bob_half)
	return r


static func _bob(r: TextureRect, half := 1.25) -> void:
	if not is_instance_valid(r):
		return
	# Translate the whole rect. Tweening offset_top alone resizes the box and
	# makes small sprites look like they are jittering.
	var tw := r.create_tween()
	tw.set_loops()
	tw.set_trans(Tween.TRANS_SINE)
	tw.set_ease(Tween.EASE_IN_OUT)
	var amp := 4.0
	tw.tween_property(r, "offset_top", amp, half)
	tw.parallel().tween_property(r, "offset_bottom", amp, half)
	tw.tween_property(r, "offset_top", 0.0, half)
	tw.parallel().tween_property(r, "offset_bottom", 0.0, half)


static func hotspot(parent: Control, label: String, x: float, y: float, w: float, h: float, cb: Callable, spark_host: Node = null) -> Button:
	var b := Button.new()
	b.flat = true
	b.tooltip_text = label
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.modulate = Color(1, 1, 1, 0)
	fill_pct(b, x, y, w, h)
	b.mouse_entered.connect(func() -> void: b.modulate = Color(0.91, 0.77, 0.42, 0.28))
	b.mouse_exited.connect(func() -> void: b.modulate = Color(1, 1, 1, 0))
	var host: Node = spark_host if spark_host else parent
	b.button_down.connect(func() -> void: _hotspot_press(b, host))
	b.pressed.connect(cb)
	parent.add_child(b)
	return b


static func _hotspot_press(b: Button, host: Node) -> void:
	b.modulate = Color(0.91, 0.77, 0.42, 0.45)
	var tw := b.create_tween()
	tw.tween_property(b, "modulate", Color(1, 1, 1, 0), 0.32)
	spark_at(host, b.get_global_rect().get_center())


static func spark_at(host: Node, global_pos: Vector2) -> void:
	if host == null or not is_instance_valid(host):
		return
	boot()
	var p := CPUParticles2D.new()
	p.z_index = 40
	p.emitting = false
	p.one_shot = true
	p.amount = 12
	p.lifetime = 0.42
	p.explosiveness = 0.92
	p.randomness = 0.35
	p.texture = load("res://assets/art/sparkle.png")
	p.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 10.0
	p.direction = Vector2(0, -1)
	p.spread = 180
	p.gravity = Vector2(0, 28)
	p.initial_velocity_min = 18
	p.initial_velocity_max = 64
	p.scale_amount_min = 0.12
	p.scale_amount_max = 0.32
	p.color = GOLD
	var grad := Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 0.4, 1.0])
	grad.colors = PackedColorArray([Color(1, 1, 1, 1), GOLD, Color(GOLD.r, GOLD.g, GOLD.b, 0)])
	p.color_ramp = grad
	host.add_child(p)
	p.global_position = global_pos
	p.restart()
	p.emitting = true
	p.finished.connect(p.queue_free)


static func backdrop(parent: Control, path: String) -> TextureRect:
	var bg := TextureRect.new()
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	bg.texture = load(path)
	bg.layout_mode = 1
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.anchor_left = 0
	bg.anchor_top = 0
	bg.anchor_right = 1
	bg.anchor_bottom = 1
	parent.add_child(bg)
	return bg


static func panel_style(gold_border := true) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.047, 0.063, 0.157, 0.86)
	if gold_border:
		s.border_color = Color(0.906, 0.773, 0.416, 0.45)
		s.set_border_width_all(1)
	s.set_corner_radius_all(16)
	s.content_margin_left = 12
	s.content_margin_right = 12
	s.content_margin_top = 8
	s.content_margin_bottom = 8
	return s


static func ghost_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0, 0, 0, 0)
	s.border_color = Color(0.957, 0.937, 0.894, 0.4)
	s.set_border_width_all(1)
	s.set_corner_radius_all(999)
	s.content_margin_left = 14
	s.content_margin_right = 14
	s.content_margin_top = 8
	s.content_margin_bottom = 8
	return s


static func moment_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.043, 0.063, 0.149, 0.97)
	s.border_color = GOLD
	s.set_border_width_all(3)
	s.set_corner_radius_all(8)
	s.content_margin_left = 22
	s.content_margin_right = 22
	s.content_margin_top = 18
	s.content_margin_bottom = 16
	return s


static func primary_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = GOLD
	s.set_corner_radius_all(999)
	s.content_margin_left = 16
	s.content_margin_right = 16
	s.content_margin_top = 8
	s.content_margin_bottom = 8
	return s
