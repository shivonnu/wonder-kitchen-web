class_name GizmoFx
extends Control

var busy := false
var _spot: Dictionary = {}
var _circle_tex: Texture2D
var _square_tex: Texture2D
var _tri_tex: Texture2D
var _heart_tex: Texture2D

const STAGE := Vector2(1280.0, 720.0)
const CLOCK_FACE_POS := Vector2(241, 12)
const CLOCK_HUB := Vector2(331, 110)
const CLOCK_RAD := 78.0
const WELL := Vector2(627, 446)
const CAVE_MOUTH := Vector2(1126, 280)
const FLOOR_CRYSTAL := Vector2(1195, 582)
const WINDOW_SKY := Vector2(848, 132)
const TEX := 64.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = false
	z_as_relative = false
	set_anchors_preset(Control.PRESET_FULL_RECT)
	layout_mode = 1


func play(kind: String, spot: Dictionary = {}) -> void:
	if busy:
		return
	busy = true
	_spot = spot
	Art.boot()
	var host := get_parent() as Control
	var tries := 0
	while host != null and host.size.x < 8.0 and tries < 10:
		await get_tree().process_frame
		tries += 1
	match kind:
		"clock":
			await _play_clock()
		"lamp":
			await _play_lamp()
		"sink":
			await _play_sink()
		"shelf":
			await _play_shelf()
		"floorCrystal":
			await _play_floor_crystal()
		"wallStars":
			await _play_wall_stars()
		"table":
			await _play_table()
		"bench":
			await _play_bench()
		"pot":
			await _play_pot()
		"emptySalt":
			await _play_empty_salt()
		"memoSpot":
			await _play_memo()
		"clouds":
			await _play_clouds()
		"nearStars":
			await _play_near_stars()
		"meteor":
			await _play_meteor()
		"footprints":
			await _play_footprints()
		"road":
			await _play_road()
		"furrows":
			await _play_furrows()
		"hills":
			await _play_hills()
		"rocks":
			await _play_rocks()
		"littleCrater":
			await _play_little_crater()
		"earth":
			await _play_earth()
		"crater":
			await _play_crater()
		"stalactite":
			await _play_stalactite()
		"echo":
			await _play_echo()
		"caveClock":
			await _play_cave_clock()
		"caveShelf":
			await _play_cave_shelf()
		"caveSink":
			await _play_cave_sink()
		"cavePot":
			await _play_cave_pot()
		"caveWindow":
			await _play_cave_window()
		"caveLamp":
			await _play_cave_lamp()
		"caveJar":
			await _play_cave_jar()
		"caveCrystals":
			await _play_cave_crystals()
		_:
			pass
	_clear()
	busy = false


func _clear() -> void:
	for c in get_children():
		remove_child(c)
		c.free()


func _world() -> Node2D:
	_clear()
	var world := Node2D.new()
	world.z_index = 20
	var host := get_parent() as Control
	var stage := host.size if host != null and host.size.x > 8.0 else size
	if stage.x < 8.0:
		stage = STAGE
	world.scale = Vector2(stage.x / STAGE.x, stage.y / STAGE.y)
	add_child(world)
	return world


func _hub() -> Vector2:
	var x := float(_spot.get("x", 50.0))
	var y := float(_spot.get("y", 50.0))
	var w := float(_spot.get("w", 10.0))
	var h := float(_spot.get("h", 10.0))
	return Vector2((x + w * 0.5) / 100.0 * STAGE.x, (y + h * 0.5) / 100.0 * STAGE.y)


func _spot_rect() -> Rect2:
	var x := float(_spot.get("x", 50.0)) / 100.0 * STAGE.x
	var y := float(_spot.get("y", 50.0)) / 100.0 * STAGE.y
	var w := float(_spot.get("w", 10.0)) / 100.0 * STAGE.x
	var h := float(_spot.get("h", 10.0)) / 100.0 * STAGE.y
	return Rect2(x, y, w, h)


func _ok(n: Node) -> bool:
	return is_instance_valid(n) and is_inside_tree()


func _pause(world: Node, sec: float) -> bool:
	if not _ok(world):
		return false
	await get_tree().create_timer(sec).timeout
	return _ok(world)


func _tex_circle() -> Texture2D:
	if _circle_tex:
		return _circle_tex
	var n := int(TEX)
	var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var c := Vector2((n - 1) * 0.5, (n - 1) * 0.5)
	var r := float(n) * 0.5 - 0.6
	for y in n:
		for x in n:
			if Vector2(float(x), float(y)).distance_to(c) <= r:
				img.set_pixel(x, y, Color.WHITE)
	_circle_tex = ImageTexture.create_from_image(img)
	return _circle_tex


func _tex_square() -> Texture2D:
	if _square_tex:
		return _square_tex
	var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	_square_tex = ImageTexture.create_from_image(img)
	return _square_tex


func _tex_tri() -> Texture2D:
	if _tri_tex:
		return _tri_tex
	var n := int(TEX)
	var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var a := Vector2(float(n) * 0.5, 1.0)
	var b := Vector2(float(n) - 1.0, float(n) - 1.0)
	var c := Vector2(1.0, float(n) - 1.0)
	var den := (b.y - c.y) * (a.x - c.x) + (c.x - b.x) * (a.y - c.y)
	for y in n:
		for x in n:
			var p := Vector2(float(x), float(y))
			var u := ((b.y - c.y) * (p.x - c.x) + (c.x - b.x) * (p.y - c.y)) / den
			var v := ((c.y - a.y) * (p.x - c.x) + (a.x - c.x) * (p.y - c.y)) / den
			var w := 1.0 - u - v
			if u >= 0.0 and v >= 0.0 and w >= 0.0:
				img.set_pixel(x, y, Color.WHITE)
	_tri_tex = ImageTexture.create_from_image(img)
	return _tri_tex


func _tex_heart() -> Texture2D:
	if _heart_tex:
		return _heart_tex
	var n := int(TEX)
	var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var cx := (n - 1) * 0.5
	var cy := (n - 1) * 0.42
	var s := float(n) * 0.28
	for y in n:
		for x in n:
			var px := (float(x) - cx) / s
			var py := (cy - float(y)) / s
			var a := px * px + py * py - 1.0
			if a * a * a - px * px * py * py * py <= 0.0:
				img.set_pixel(x, y, Color.WHITE)
	_heart_tex = ImageTexture.create_from_image(img)
	return _heart_tex


func _blob(world: Node2D, tex: Texture2D, pos: Vector2, px: Vector2, color: Color, z: int) -> Node2D:
	var hold := Node2D.new()
	hold.position = pos
	hold.z_index = z
	hold.modulate = color
	var s := Sprite2D.new()
	s.texture = tex
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	s.centered = true
	var tw := float(tex.get_width())
	var th := float(tex.get_height())
	if tw > 1.0 and th > 1.0:
		s.scale = Vector2(px.x / tw, px.y / th)
	hold.add_child(s)
	world.add_child(hold)
	return hold


func _disc(world: Node2D, pos: Vector2, r: float, color: Color, z := 4) -> Node2D:
	return _blob(world, _tex_circle(), pos, Vector2(r * 2.0, r * 2.0), color, z)


func _box(world: Node2D, pos: Vector2, size: Vector2, color: Color, z := 4) -> Node2D:
	return _blob(world, _tex_square(), pos, size, color, z)


func _tri(world: Node2D, pos: Vector2, size: Vector2, color: Color, z := 4) -> Node2D:
	var hold := _blob(world, _tex_tri(), pos, size, color, z)
	var spr := hold.get_child(0) as Sprite2D
	if spr:
		spr.offset = Vector2(0.0, TEX * 0.5)
	return hold


func _word(world: Node2D, pos: Vector2, text: String, color: Color, px := 52) -> Label:
	var l := Label.new()
	l.text = text
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_color_override("font_color", color)
	l.add_theme_font_size_override("font_size", px)
	l.add_theme_color_override("font_outline_color", Color(0.05, 0.07, 0.12, 0.92))
	l.add_theme_constant_override("outline_size", 8)
	if Art.font:
		l.add_theme_font_override("font", Art.font)
	l.position = pos + Vector2(-40, -22)
	l.z_index = 16
	world.add_child(l)
	return l


func _spray(world: Node2D, pos: Vector2, color: Color, n := 14, rad := 150.0) -> void:
	if not _ok(world):
		return
	var origin := world.to_global(pos)
	for i in n:
		var s := Sprite2D.new()
		s.texture = load("res://assets/art/sparkle.png")
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		s.centered = true
		s.modulate = color
		s.scale = Vector2(6.2, 6.2)
		s.z_index = 30
		s.z_as_relative = false
		add_child(s)
		s.global_position = origin
		var a := TAU * float(i) / float(n)
		var dest := origin + Vector2(cos(a), sin(a)) * rad
		var tw := create_tween()
		tw.tween_property(s, "global_position", dest, 0.62).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(s, "modulate:a", 0.0, 0.62)
		tw.parallel().tween_property(s, "scale", Vector2(1.4, 1.4), 0.62)


func _puff(world: Node2D, pos: Vector2, color: Color, n := 16, life := 0.55, vel := 90.0, grav := Vector2(0, 40), dir := Vector2(0, -1), spread := 180.0) -> void:
	if not _ok(world):
		return
	var p := CPUParticles2D.new()
	p.z_index = 28
	p.z_as_relative = false
	p.emitting = false
	p.one_shot = true
	p.amount = maxi(n, 16)
	p.lifetime = life
	p.explosiveness = 0.88
	p.texture = load("res://assets/art/sparkle.png")
	p.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	p.direction = dir
	p.spread = spread
	p.gravity = grav
	p.initial_velocity_min = vel * 0.45
	p.initial_velocity_max = vel * 1.35
	p.scale_amount_min = 1.35
	p.scale_amount_max = 2.8
	p.color = color
	add_child(p)
	p.global_position = world.to_global(pos)
	p.restart()
	p.emitting = true
	p.finished.connect(p.queue_free)


func _begin(color: Color = Art.GOLD) -> Node2D:
	var world := _world()
	if _ok(world):
		var hub := _hub()
		_ripple(world, hub, color, 36.0)
		_spray(world, hub, color)
		_puff(world, hub, color, 20, 0.55, 110.0)
	return world


func _spr_fit(world: Node2D, path: String, pos: Vector2, target_h: float) -> Sprite2D:
	var s := _spr(world, path, pos, 1.0)
	if s.texture:
		var th := float(s.texture.get_height())
		if th > 1.0:
			var sc := target_h / th
			s.scale = Vector2(sc, sc)
	return s


func _spr(parent: Node, path: String, pos: Vector2, sc: float) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = load(path)
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.material = Art.chroma
	s.centered = true
	s.position = pos
	s.scale = Vector2(sc, sc)
	parent.add_child(s)
	return s


func _ripple(world: Node2D, pos: Vector2, color: Color, start_r := 36.0) -> void:
	var ring := _disc(world, pos, start_r, color, 5)
	ring.modulate.a = minf(ring.modulate.a, 0.75)
	var tw := create_tween()
	tw.tween_property(ring, "scale", Vector2(3.6, 3.6), 0.7).set_trans(Tween.TRANS_QUAD)
	tw.parallel().tween_property(ring, "modulate:a", 0.0, 0.7)


# --- clock (kitchen) ---------------------------------------------------------

func _play_clock() -> void:
	var world := _world()
	if not _ok(world):
		return

	var face := Sprite2D.new()
	face.texture = load("res://assets/art/clock-face.png")
	face.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	face.centered = false
	face.position = CLOCK_FACE_POS
	world.add_child(face)

	var hour := _hand(world, (CLOCK_RAD * 0.58) / 115.0, 228.0)
	var minute := _hand(world, (CLOCK_RAD * 0.88) / 115.0, 48.0)

	var hatch := Vector2(CLOCK_HUB.x, CLOCK_HUB.y - 44.0)
	var door := _spr(world, "res://assets/art/clock-door.png", hatch, 0.72)
	if door.texture:
		door.offset = Vector2(0.0, -door.texture.get_height() * 0.42)
	door.visible = false
	door.z_index = 3

	var bird := _spr(world, "res://assets/art/clock-bird.png", hatch, 0.28)
	bird.visible = false
	bird.z_index = 4

	if not await _pause(world, 0.08):
		return

	var spin := create_tween()
	spin.set_trans(Tween.TRANS_QUAD)
	spin.set_ease(Tween.EASE_IN)
	spin.tween_property(minute, "rotation_degrees", minute.rotation_degrees + 1620.0, 1.65)
	spin.parallel().tween_property(hour, "rotation_degrees", hour.rotation_degrees + 880.0, 1.65)
	await spin.finished
	if not _ok(world):
		return

	door.visible = true
	var open_tw := create_tween()
	open_tw.tween_property(door, "rotation_degrees", -82.0, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await open_tw.finished
	if not _ok(world):
		return

	bird.visible = true
	bird.scale = Vector2(0.16, 0.16)
	var perch := Vector2(CLOCK_HUB.x + 6.0, CLOCK_HUB.y - 52.0)
	var pop := create_tween()
	pop.set_trans(Tween.TRANS_BACK)
	pop.set_ease(Tween.EASE_OUT)
	pop.tween_property(bird, "position", perch, 0.28)
	pop.parallel().tween_property(bird, "scale", Vector2(0.42, 0.42), 0.28)
	await pop.finished
	if not _ok(world):
		return

	Art.spark_at(self, bird.to_global(Vector2.ZERO))
	var bob := create_tween()
	bob.tween_property(bird, "position:y", perch.y - 6.0, 0.12)
	bob.tween_property(bird, "position:y", perch.y + 2.0, 0.16)
	await bob.finished
	if not await _pause(world, 0.32):
		return

	var back := create_tween()
	back.tween_property(bird, "position", hatch, 0.16)
	back.parallel().tween_property(bird, "scale", Vector2(0.14, 0.14), 0.16)
	back.tween_property(door, "rotation_degrees", 0.0, 0.12)
	await back.finished
	if not _ok(world):
		return

	bird.visible = false
	door.visible = false
	hour.rotation_degrees = 228.0
	minute.rotation_degrees = 48.0
	await _pause(world, 0.22)


func _hand(world: Node2D, sc: float, degrees: float) -> Sprite2D:
	var s := _spr(world, "res://assets/art/clock-hand.png", CLOCK_HUB, sc)
	if s.texture:
		s.offset = Vector2(0.0, -s.texture.get_height() * 0.40)
	s.rotation_degrees = degrees
	s.z_index = 2
	return s


# --- kitchen -----------------------------------------------------------------

func _play_lamp() -> void:
	var world := _world()
	if not _ok(world):
		return
	var hub := _hub()
	var glow := _disc(world, hub, CLOCK_RAD, Color(0.91, 0.77, 0.42, 0.0), 3)
	glow.scale = Vector2(0.72, 0.72)
	var grow := create_tween()
	grow.tween_property(glow, "scale", Vector2(1.0, 1.0), 0.4).set_trans(Tween.TRANS_SINE)
	grow.parallel().tween_property(glow, "modulate:a", 0.5, 0.4)
	if not await _pause(world, 0.18):
		return

	var dests: Array[Vector2] = [
		Vector2(210, 150),
		Vector2(430, 88),
		Vector2(640, 170),
		Vector2(880, 110),
		Vector2(220, 390),
		Vector2(540, 330),
		Vector2(980, 390),
		Vector2(720, 500),
	]
	var kinds := ["circle", "heart", "diamond", "circle", "heart", "diamond", "circle", "heart"]
	var cols := [
		Art.SALT,
		Color(1.0, 0.86, 0.9, 1.0),
		Art.GOLD,
		Color(0.86, 0.93, 1.0, 1.0),
		Art.GOLD,
		Art.SALT,
		Color(1.0, 0.92, 0.78, 1.0),
		Color(0.9, 0.84, 1.0, 1.0),
	]
	var chunks: Array[Node2D] = []
	for i in dests.size():
		if not _ok(world):
			return
		var ch := _salt_dream(world, hub, kinds[i], cols[i])
		chunks.append(ch)
		_fly_salt(ch, hub, dests[i], 0.95 + float(i) * 0.03)
		if i < dests.size() - 1:
			if not await _pause(world, 0.06):
				return
	if not await _pause(world, 1.05):
		return

	var wrap := create_tween()
	for ch in chunks:
		if not _ok(ch):
			continue
		var halo := ch.get_node_or_null("halo") as Node2D
		if halo:
			wrap.parallel().tween_property(halo, "modulate:a", 0.46, 0.55).set_trans(Tween.TRANS_SINE)
			wrap.parallel().tween_property(halo, "scale", Vector2(1.0, 1.0), 0.55)
	var dim := create_tween()
	dim.tween_property(glow, "modulate:a", 0.12, 0.6)
	await wrap.finished
	if not _ok(world):
		return
	if not await _pause(world, 2.4):
		return
	var fade := create_tween()
	fade.set_trans(Tween.TRANS_SINE)
	for ch in chunks:
		if _ok(ch):
			fade.parallel().tween_property(ch, "modulate:a", 0.0, 2.0)
	fade.parallel().tween_property(glow, "modulate:a", 0.0, 2.0)
	await fade.finished


func _salt_dream(world: Node2D, pos: Vector2, kind: String, color: Color) -> Node2D:
	var hold := Node2D.new()
	hold.position = pos
	hold.z_index = 8
	world.add_child(hold)
	var halo := _disc(hold, Vector2.ZERO, 30.0, Color(1.0, 0.95, 0.82, 0.0), 0)
	halo.name = "halo"
	halo.scale = Vector2(0.22, 0.22)
	var salt: Node2D
	match kind:
		"heart":
			salt = _blob(hold, _tex_heart(), Vector2.ZERO, Vector2(26, 26), color, 2)
		"diamond":
			salt = _box(hold, Vector2.ZERO, Vector2(20, 20), color, 2)
			var spr := salt.get_child(0) as Sprite2D
			if spr:
				spr.rotation_degrees = 45.0
		_:
			salt = _disc(hold, Vector2.ZERO, 11.0, color, 2)
	salt.name = "salt"
	return hold


func _fly_salt(hold: Node2D, start: Vector2, dest: Vector2, dur: float) -> void:
	var arc := 42.0 + float(randi() % 28)
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_CUBIC)
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_method(func(t: float) -> void:
		if not _ok(hold):
			return
		hold.position = start.lerp(dest, t) + Vector2(0.0, -sin(t * PI) * arc)
	, 0.0, 1.0, dur)


func _play_sink() -> void:
	var world := _world()
	if not _ok(world):
		return
	var turning_on := not GameState.has_flag("kitchenFaucet")
	var tap := Vector2(64, 366)
	var spout := Vector2(116, 350)
	var glow := _disc(world, tap, CLOCK_RAD, Color(0.91, 0.77, 0.42, 0.0), 3)
	glow.scale = Vector2(0.72, 0.72)
	var grow := create_tween()
	grow.tween_property(glow, "scale", Vector2(1.0, 1.0), 0.28).set_trans(Tween.TRANS_SINE)
	grow.parallel().tween_property(glow, "modulate:a", 0.5, 0.28)

	var handle := Node2D.new()
	handle.position = tap
	handle.z_index = 8
	world.add_child(handle)
	_box(handle, Vector2.ZERO, Vector2(44, 8), Color(0.93, 0.82, 0.52, 0.95), 8)
	_box(handle, Vector2(0, 9), Vector2(9, 16), Color(0.85, 0.75, 0.45, 0.95), 8)
	handle.rotation_degrees = 0.0 if turning_on else 72.0
	var twist := create_tween()
	twist.tween_property(handle, "rotation_degrees", 72.0 if turning_on else 0.0, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await twist.finished
	if not _ok(world):
		return
	GameState.toggle_flag("kitchenFaucet")
	if turning_on:
		GameState.say("流し", "水のかわりに、うすい星くずがさらさら流れている。つめたい。")
		_puff(world, spout, Art.SALT, 10, 0.4, 42.0, Vector2(0, 90), Vector2(0, 1), 14.0)
	else:
		GameState.say("流し", "水をとめた。もう一度ひねれば、また出るよ。")
	if not await _pause(world, 0.28):
		return
	var fade := create_tween()
	fade.tween_property(glow, "modulate:a", 0.0, 0.32)
	fade.parallel().tween_property(handle, "modulate:a", 0.0, 0.32)
	await fade.finished


func _play_shelf() -> void:
	var host := get_parent() as AdventureScreen
	if host:
		host.set_kitchen_actors_visible(false)
	await _shelf_seq()
	_clear()
	if host and is_instance_valid(host):
		host.set_kitchen_actors_visible(true)


func _shelf_seq() -> void:
	var world := _world()
	if not _ok(world):
		return

	var jar_rest := Vector2(227.0, 195.5)
	var jar_hold := Vector2(252.0, 186.0)
	var shion_home := Vector2(460.8, 453.6)
	var shion_jar := Vector2(292.0, 208.0)
	var pepper := Color(0.62, 0.32, 0.14, 0.95)

	var glow := _disc(world, jar_rest, CLOCK_RAD, Color(0.91, 0.77, 0.42, 0.0), 3)
	glow.scale = Vector2(0.72, 0.72)
	var grow := create_tween()
	grow.tween_property(glow, "scale", Vector2(1.0, 1.0), 0.35).set_trans(Tween.TRANS_SINE)
	grow.parallel().tween_property(glow, "modulate:a", 0.5, 0.35)

	var jar := Node2D.new()
	jar.position = jar_rest
	jar.z_index = 8
	world.add_child(jar)
	var body := _spr(jar, "res://assets/art/pepper-jar-body.png", Vector2.ZERO, 1.0)
	body.z_index = 0
	var lid := _spr(jar, "res://assets/art/pepper-jar-lid.png", Vector2.ZERO, 1.0)
	lid.z_index = 2

	var shion := _spr(world, "res://assets/art/shion-idle.png", shion_home, 1.0)
	shion.z_index = 10
	if shion.texture:
		var atlas := AtlasTexture.new()
		atlas.atlas = shion.texture
		atlas.region = Rect2(0.0, 0.0, shion.texture.get_width() * 0.5, shion.texture.get_height())
		shion.texture = atlas
		var th := float(atlas.get_height())
		if th > 1.0:
			shion.scale = Vector2.ONE * (130.0 / th)

	# しおんがテーブルから右端のビンの横へ。2秒。
	var arrive := create_tween()
	arrive.set_trans(Tween.TRANS_SINE)
	arrive.set_ease(Tween.EASE_IN_OUT)
	var start := shion_home
	arrive.tween_method(func(t: float) -> void:
		if not _ok(shion):
			return
		shion.position = start.lerp(shion_jar, t) + Vector2(0.0, -sin(t * PI) * 70.0)
	, 0.0, 1.0, 2.0)
	await arrive.finished
	if not _ok(world):
		return

	# 蓋を開けて、ビンを少し手前へ。2秒。
	var open := create_tween()
	open.set_trans(Tween.TRANS_SINE)
	open.set_ease(Tween.EASE_OUT)
	open.tween_property(lid, "position:y", -26.0, 2.0)
	open.parallel().tween_property(lid, "rotation_degrees", -16.0, 2.0)
	open.parallel().tween_property(jar, "position", jar_hold, 2.0)
	open.parallel().tween_property(shion, "rotation_degrees", -8.0, 2.0)
	await open.finished
	if not _ok(world):
		return

	# よろこんで吸い込む。2秒。
	var mouth := jar.position + Vector2(0.0, -22.0)
	_puff(world, mouth, Color(0.95, 0.88, 0.78, 0.9), 12, 0.7, 28.0, Vector2(0, 8), (shion.position - mouth).normalized(), 18.0)
	var heart_a := _blob(world, _tex_heart(), shion.position + Vector2(-10, -36), Vector2(18, 18), Color(1.0, 0.72, 0.82, 0.95), 12)
	var heart_b := _blob(world, _tex_heart(), shion.position + Vector2(16, -28), Vector2(12, 12), Color(1.0, 0.82, 0.7, 0.9), 12)
	var inhale := create_tween()
	inhale.set_trans(Tween.TRANS_SINE)
	inhale.tween_property(shion, "scale", shion.scale * 1.12, 0.7)
	inhale.parallel().tween_property(shion, "position", shion_jar + Vector2(-10, -6), 0.7)
	inhale.tween_property(shion, "scale", shion.scale, 0.6)
	inhale.parallel().tween_property(heart_a, "position:y", heart_a.position.y - 22.0, 1.3)
	inhale.parallel().tween_property(heart_a, "modulate:a", 0.0, 1.3)
	inhale.parallel().tween_property(heart_b, "position:y", heart_b.position.y - 18.0, 1.3)
	inhale.parallel().tween_property(heart_b, "modulate:a", 0.0, 1.3)
	if not await _pause(world, 2.0):
		return

	# こしょうだったのでくしゃみ。3秒。
	GameState.say("しおん", "っくしゅんっ！ …こしょうだ。")
	_puff(world, mouth, pepper, 22, 0.85, 70.0, Vector2(0, 40), Vector2(0.55, -0.7), 70.0)
	_puff(world, shion.position + Vector2(8, -8), pepper, 10, 0.5, 42.0, Vector2(0, 30), Vector2(0.4, -1), 50.0)
	var sneeze := create_tween()
	sneeze.tween_property(shion, "rotation_degrees", 14.0, 0.08)
	sneeze.tween_property(shion, "rotation_degrees", -16.0, 0.08)
	sneeze.tween_property(shion, "position", shion_jar + Vector2(14, 6), 0.1)
	for _i in 6:
		sneeze.tween_property(shion, "position:x", shion_jar.x + 10.0, 0.07)
		sneeze.tween_property(shion, "position:x", shion_jar.x - 10.0, 0.07)
	sneeze.tween_property(shion, "position", shion_jar, 0.18)
	sneeze.parallel().tween_property(shion, "rotation_degrees", 0.0, 0.18)
	if not await _pause(world, 1.15):
		return
	_puff(world, mouth, pepper, 8, 0.4, 28.0, Vector2(0, 20), Vector2(0.2, -1), 40.0)
	if not await _pause(world, 1.85):
		return

	# 蓋を閉めて右端へ戻し、しおんもテーブルへ。3秒。
	var back := create_tween()
	back.set_trans(Tween.TRANS_SINE)
	back.set_ease(Tween.EASE_IN_OUT)
	back.tween_property(lid, "position:y", 0.0, 0.7)
	back.parallel().tween_property(lid, "rotation_degrees", 0.0, 0.7)
	back.parallel().tween_property(jar, "position", jar_rest, 3.0)
	var home := shion.position
	back.parallel().tween_method(func(t: float) -> void:
		if not _ok(shion):
			return
		shion.position = home.lerp(shion_home, t) + Vector2(0.0, -sin(t * PI) * 56.0)
		shion.rotation_degrees = lerpf(shion.rotation_degrees, 0.0, t)
	, 0.0, 1.0, 3.0)
	back.parallel().tween_property(glow, "modulate:a", 0.0, 1.2)
	await back.finished


func _play_floor_crystal() -> void:
	var world := _world()
	if not _ok(world):
		return
	var crystal := FLOOR_CRYSTAL
	var sky := WINDOW_SKY

	var glow := _disc(world, crystal, CLOCK_RAD, Color(0.91, 0.77, 0.42, 0.0), 3)
	glow.scale = Vector2(0.72, 0.72)
	var grow := create_tween()
	grow.tween_property(glow, "scale", Vector2(1.0, 1.0), 0.32).set_trans(Tween.TRANS_SINE)
	grow.parallel().tween_property(glow, "modulate:a", 0.5, 0.32)
	_puff(world, crystal, Art.SALT, 16, 0.55, 36.0)

	var hold := Node2D.new()
	hold.position = crystal
	hold.z_index = 12
	hold.scale = Vector2(0.08, 0.08)
	hold.modulate = Color(0.82, 0.93, 1.0, 0.0)
	world.add_child(hold)
	_disc(hold, Vector2.ZERO, 34.0, Color(0.85, 0.93, 1.0, 0.35), 0)
	var bunny := _spr(hold, "res://assets/art/luna-idle.png", Vector2.ZERO, 1.0)
	bunny.z_index = 2
	if bunny.texture:
		var atlas := AtlasTexture.new()
		atlas.atlas = bunny.texture
		atlas.region = Rect2(0.0, 0.0, bunny.texture.get_width() * 0.5, bunny.texture.get_height())
		bunny.texture = atlas
		var th := float(atlas.get_height())
		if th > 1.0:
			bunny.scale = Vector2.ONE * (168.0 / th)

	# 結晶から塩のウサギが出る。2秒。
	var emerge := create_tween()
	emerge.set_trans(Tween.TRANS_SINE)
	emerge.tween_property(hold, "modulate:a", 1.0, 0.4)
	emerge.parallel().tween_property(hold, "scale", Vector2.ONE, 0.85).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	emerge.parallel().tween_property(hold, "position", crystal + Vector2(-16, -54), 0.85)
	emerge.tween_property(hold, "position:y", crystal.y - 92.0, 0.28).set_ease(Tween.EASE_OUT)
	emerge.tween_property(hold, "position:y", crystal.y - 50.0, 0.32).set_ease(Tween.EASE_IN)
	emerge.tween_property(hold, "position:y", crystal.y - 78.0, 0.25).set_ease(Tween.EASE_OUT)
	emerge.tween_property(hold, "position:y", crystal.y - 52.0, 0.3).set_ease(Tween.EASE_IN)
	await emerge.finished
	if not _ok(world):
		return

	# 窓へ飛び出す。3秒。
	var start := hold.position
	var leap := create_tween()
	leap.set_trans(Tween.TRANS_SINE)
	leap.set_ease(Tween.EASE_IN_OUT)
	leap.tween_method(func(t: float) -> void:
		if not _ok(hold):
			return
		hold.position = start.lerp(sky, t) + Vector2(0.0, -sin(t * PI) * 210.0)
		hold.scale = Vector2.ONE.lerp(Vector2(0.48, 0.48), t)
		hold.rotation_degrees = lerpf(-6.0, 12.0, t)
	, 0.0, 1.0, 3.0)
	leap.parallel().tween_property(glow, "modulate:a", 0.12, 1.4)
	await leap.finished
	if not _ok(world):
		return

	# 夜空で星座になる。2秒。
	var pts: Array[Vector2] = [
		sky + Vector2(-24, -74),
		sky + Vector2(22, -70),
		sky + Vector2(-12, -40),
		sky + Vector2(14, -36),
		sky + Vector2(4, -16),
		sky + Vector2(-4, 10),
		sky + Vector2(38, 6),
		sky + Vector2(-30, 38),
		sky + Vector2(16, 44),
	]
	var links: Array = [
		[0, 2], [1, 3], [2, 3], [2, 4], [3, 4], [4, 5], [4, 6], [5, 7], [5, 8], [6, 8],
	]
	var stars: Array[Node2D] = []
	var lines: Array[Node2D] = []
	for i in pts.size():
		var col := Art.GOLD if i % 2 == 0 else Art.SALT
		var st := _disc(world, pts[i], 9.0, col, 14)
		st.scale = Vector2(0.12, 0.12)
		st.modulate.a = 0.0
		stars.append(st)
	for pair in links:
		var a: Vector2 = pts[int(pair[0])]
		var b: Vector2 = pts[int(pair[1])]
		var ln := _box(world, (a + b) * 0.5, Vector2(a.distance_to(b), 2.4), Color(0.91, 0.77, 0.42, 0.0), 13)
		ln.rotation = (b - a).angle()
		ln.modulate.a = 0.0
		lines.append(ln)
	var form := create_tween()
	form.set_trans(Tween.TRANS_BACK)
	form.set_ease(Tween.EASE_OUT)
	form.tween_property(hold, "modulate:a", 0.0, 0.45)
	form.parallel().tween_property(hold, "scale", Vector2(0.12, 0.12), 0.45)
	for i in stars.size():
		form.parallel().tween_property(stars[i], "modulate:a", 1.0, 0.28).set_delay(0.12 + float(i) * 0.1)
		form.parallel().tween_property(stars[i], "scale", Vector2.ONE, 0.32).set_delay(0.12 + float(i) * 0.1)
	for ln in lines:
		form.parallel().tween_property(ln, "modulate:a", 0.72, 0.55).set_delay(0.55)
	if not await _pause(world, 2.0):
		return

	# うっすら消える。3秒。
	var fade := create_tween()
	fade.set_trans(Tween.TRANS_SINE)
	for st in stars:
		if _ok(st):
			fade.parallel().tween_property(st, "modulate:a", 0.0, 3.0)
	for ln in lines:
		if _ok(ln):
			fade.parallel().tween_property(ln, "modulate:a", 0.0, 3.0)
	fade.parallel().tween_property(glow, "modulate:a", 0.0, 1.6)
	await fade.finished


func _play_wall_stars() -> void:
	var world := _world()
	if not _ok(world):
		return
	var hub := _hub()
	var glow := _disc(world, hub, CLOCK_RAD, Color(0.91, 0.77, 0.42, 0.0), 3)
	glow.scale = Vector2(0.72, 0.72)
	var grow := create_tween()
	grow.tween_property(glow, "scale", Vector2(1.0, 1.0), 0.32).set_trans(Tween.TRANS_SINE)
	grow.parallel().tween_property(glow, "modulate:a", 0.5, 0.32)

	# 壁に焼き込まれた星くず + 起き上がる細かい粒。
	var specs: Array[Dictionary] = [
		{"p": Vector2(513, 28), "r": 8.0, "s": 0.42, "home": true},
		{"p": Vector2(546, 31), "r": 5.0, "s": 0.22, "home": true},
		{"p": Vector2(609, 55), "r": 6.0, "s": 0.28, "home": true},
		{"p": Vector2(476, 66), "r": 5.0, "s": 0.22, "home": true},
		{"p": Vector2(493, 74), "r": 5.0, "s": 0.2, "home": true},
		{"p": Vector2(487, 108), "r": 5.0, "s": 0.18, "home": true},
		{"p": Vector2(659, 45), "r": 5.0, "s": 0.2, "home": true},
		{"p": Vector2(705, 65), "r": 11.0, "s": 0.55, "home": true},
		{"p": Vector2(649, 192), "r": 5.0, "s": 0.2, "home": true},
		{"p": Vector2(558, 44), "r": 0.0, "s": 0.3, "home": false},
		{"p": Vector2(582, 78), "r": 0.0, "s": 0.26, "home": false},
		{"p": Vector2(536, 96), "r": 0.0, "s": 0.24, "home": false},
		{"p": Vector2(618, 42), "r": 0.0, "s": 0.28, "home": false},
		{"p": Vector2(598, 128), "r": 0.0, "s": 0.22, "home": false},
		{"p": Vector2(548, 148), "r": 0.0, "s": 0.24, "home": false},
		{"p": Vector2(638, 98), "r": 0.0, "s": 0.26, "home": false},
		{"p": Vector2(510, 88), "r": 0.0, "s": 0.22, "home": false},
	]
	var wall := Color(0.016, 0.047, 0.122, 1.0)
	var spark_tex: Texture2D = load("res://assets/art/sparkle.png")
	var holds: Array[Node2D] = []
	var rests: Array[Vector2] = []
	var sc0: Array[float] = []
	var drift: Array[Vector2] = []
	var froms: Array[Vector2] = []
	var phases: Array[float] = []
	var homes: Array[bool] = []
	for i in specs.size():
		var spec: Dictionary = specs[i]
		var rest: Vector2 = spec["p"]
		var cr := float(spec["r"])
		if cr > 0.5:
			_disc(world, rest, cr, wall, 4)
		var hold := Node2D.new()
		hold.position = rest
		hold.z_index = 12
		hold.scale = Vector2.ONE * float(spec["s"])
		hold.modulate.a = 1.0 if bool(spec["home"]) else 0.0
		world.add_child(hold)
		var spark := Sprite2D.new()
		spark.texture = spark_tex
		spark.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spark.centered = true
		spark.modulate = Art.GOLD if i % 2 == 0 else Art.SALT
		hold.add_child(spark)
		var ang := deg_to_rad(64.0 + float(i) * 17.0)
		holds.append(hold)
		rests.append(rest)
		sc0.append(float(spec["s"]))
		drift.append(Vector2(sin(ang) * 110.0, 430.0 + float(i % 6) * 48.0))
		froms.append(Vector2(rest.x + sin(float(i) * 1.7) * 34.0, 742.0 + float(i % 4) * 14.0))
		phases.append(float(i) * 0.73)
		homes.append(bool(spec["home"]))

	# ずっと壁にいた星が、ゆっくり流れはじめて見えなくなる。5秒。
	var flow := create_tween()
	flow.set_trans(Tween.TRANS_LINEAR)
	flow.tween_method(func(t: float) -> void:
		var u := t * t
		for i in holds.size():
			var h: Node2D = holds[i]
			if not _ok(h):
				continue
			var wob := Vector2(
				sin(t * TAU * 1.15 + phases[i]) * 18.0 * t,
				cos(t * TAU * 0.85 + phases[i]) * 9.0 * t
			)
			h.position = rests[i] + drift[i] * u + wob
			var wake := 1.0 if homes[i] else minf(1.0, t / 0.14)
			h.modulate.a = wake * (1.0 - t)
			var sc := sc0[i] * (1.0 + 0.5 * t)
			h.scale = Vector2(sc, sc)
			h.rotation = sin(t * 5.0 + phases[i]) * 0.4
	, 0.0, 1.0, 5.0)
	await flow.finished
	if not _ok(world):
		return

	for i in holds.size():
		if _ok(holds[i]):
			holds[i].position = froms[i]
			holds[i].modulate.a = 0.0
			holds[i].rotation = 0.0
			var sc := sc0[i] * 1.35
			holds[i].scale = Vector2(sc, sc)

	# 下側から戻って、元の場所に収まる。5秒。
	var back := create_tween()
	back.set_trans(Tween.TRANS_LINEAR)
	back.tween_method(func(t: float) -> void:
		var u := 1.0 - (1.0 - t) * (1.0 - t)
		for i in holds.size():
			var h: Node2D = holds[i]
			if not _ok(h):
				continue
			h.position = froms[i].lerp(rests[i], u) + Vector2(0.0, -sin(t * PI) * 36.0)
			var a := minf(1.0, t / 0.2)
			if not homes[i] and t > 0.86:
				a *= (1.0 - t) / 0.14
			h.modulate.a = a
			var sc := lerpf(sc0[i] * 1.35, sc0[i], u)
			h.scale = Vector2(sc, sc)
			h.rotation = sin((1.0 - t) * 4.0 + phases[i]) * 0.28 * (1.0 - t)
	, 0.0, 1.0, 5.0)
	back.parallel().tween_property(glow, "modulate:a", 0.0, 1.4).set_delay(3.6)
	await back.finished


func _play_table() -> void:
	var world := _begin()
	if not _ok(world):
		return
	var hub := _hub()
	var board := _box(world, hub, Vector2(168, 88), Color(0.55, 0.38, 0.22, 0.0), 5)
	board.modulate.a = 0.0
	var pop := create_tween()
	pop.tween_property(board, "modulate:a", 0.92, 0.18)
	pop.parallel().tween_property(board, "scale", Vector2(1.05, 1.05), 0.18).set_trans(Tween.TRANS_BACK)
	await pop.finished
	if not await _pause(world, 0.55):
		return
	_puff(world, hub, Color(0.7, 0.55, 0.35), 8, 0.35, 30.0)
	var poof := create_tween()
	poof.tween_property(board, "scale", Vector2(0.2, 0.2), 0.22)
	poof.parallel().tween_property(board, "modulate:a", 0.0, 0.22)
	await poof.finished


func _play_bench() -> void:
	var world := _begin()
	if not _ok(world):
		return
	var hub := _hub()
	var luna := _spr_fit(world, "res://assets/art/luna-idle.png", hub + Vector2(0, 10), 140.0)
	if luna.texture:
		var atlas := AtlasTexture.new()
		atlas.atlas = luna.texture
		atlas.region = Rect2(0, 0, luna.texture.get_width() * 0.5, luna.texture.get_height())
		luna.texture = atlas
		var th := float(atlas.get_height())
		if th > 1.0:
			luna.scale = Vector2.ONE * (140.0 / th)
	luna.modulate = Color(1, 1, 1, 0.0)
	var in_tw := create_tween()
	in_tw.tween_property(luna, "modulate:a", 0.85, 0.2)
	await in_tw.finished
	if not _ok(world):
		return
	var kick := create_tween()
	kick.tween_property(luna, "rotation_degrees", 12.0, 0.16)
	kick.tween_property(luna, "rotation_degrees", -10.0, 0.18)
	kick.tween_property(luna, "rotation_degrees", 8.0, 0.16)
	kick.tween_property(luna, "rotation_degrees", 0.0, 0.14)
	await kick.finished
	if not await _pause(world, 0.2):
		return
	var out_tw := create_tween()
	out_tw.tween_property(luna, "modulate:a", 0.0, 0.28)
	out_tw.parallel().tween_property(luna, "position:y", hub.y + 18.0, 0.28)
	await out_tw.finished


func _play_pot() -> void:
	var world := _begin()
	if not _ok(world):
		return
	var hub := _hub()
	var lid := _disc(world, hub + Vector2(0, -36), 42.0, Color(0.18, 0.2, 0.28, 0.92), 5)
	lid.scale = Vector2(1.0, 0.42)
	var rattle := create_tween()
	rattle.tween_property(lid, "rotation_degrees", -14.0, 0.1)
	rattle.tween_property(lid, "rotation_degrees", 12.0, 0.1)
	rattle.tween_property(lid, "position:y", lid.position.y - 10.0, 0.12)
	rattle.tween_property(lid, "rotation_degrees", -8.0, 0.1)
	rattle.tween_property(lid, "position:y", hub.y - 36.0, 0.16)
	rattle.tween_property(lid, "rotation_degrees", 0.0, 0.1)
	_puff(world, hub + Vector2(0, -20), Color(0.85, 0.88, 0.95, 0.8), 10, 0.7, 28.0, Vector2(0, -12), Vector2(0, -1), 30.0)
	await rattle.finished
	if not _ok(world):
		return
	await _pause(world, 0.35)


func _play_empty_salt() -> void:
	var world := _begin()
	if not _ok(world):
		return
	var hub := _hub()
	var jar := _spr_fit(world, "res://assets/art/icon-salt.png", hub, 72.0)
	jar.modulate.a = 0.0
	var inn := create_tween()
	inn.tween_property(jar, "modulate:a", 1.0, 0.12)
	inn.tween_property(jar, "rotation_degrees", 28.0, 0.22).set_trans(Tween.TRANS_BACK)
	await inn.finished
	if not await _pause(world, 0.35):
		return
	var back := create_tween()
	back.tween_property(jar, "rotation_degrees", 0.0, 0.2)
	await back.finished
	if not _ok(world):
		return
	_puff(world, hub + Vector2(0, 16), Art.SALT, 12, 0.4, 36.0)
	await _pause(world, 0.3)


func _play_memo() -> void:
	var world := _begin()
	if not _ok(world):
		return
	var hub := _hub()
	var paper := _spr_fit(world, "res://assets/art/icon-memo.png", hub, 78.0)
	var flip := create_tween()
	var sx := paper.scale.x
	flip.tween_property(paper, "scale:x", 0.05, 0.16)
	flip.tween_property(paper, "scale:x", sx, 0.16)
	flip.tween_property(paper, "scale:x", 0.05, 0.14)
	flip.tween_property(paper, "scale:x", sx, 0.16)
	await flip.finished
	if not _ok(world):
		return
	_puff(world, hub, Art.GOLD, 8, 0.35, 24.0)
	await _pause(world, 0.25)


# --- star road ---------------------------------------------------------------

func _play_clouds() -> void:
	var world := _begin()
	if not _ok(world):
		return
	var hub := _hub()
	_puff(world, hub, Art.SALT, 18, 0.7, 36.0, Vector2(0, 70), Vector2(0, 1), 50.0)
	if not await _pause(world, 0.55):
		return
	_puff(world, hub + Vector2(0, 50), Art.GOLD, 12, 0.6, 40.0, Vector2(0, -20), Vector2(0, -1), 40.0)
	await _pause(world, 0.45)


func _play_near_stars() -> void:
	var world := _begin()
	if not _ok(world):
		return
	var hub := _hub()
	var star := _disc(world, hub, 32.0, Art.GOLD, 6)
	_puff(world, hub, Art.GOLD, 8, 0.35, 22.0)
	var reach := create_tween()
	reach.tween_property(star, "position", Vector2(420, 430), 0.55).set_trans(Tween.TRANS_QUAD)
	reach.parallel().tween_property(star, "scale", Vector2(1.4, 1.4), 0.55)
	await reach.finished
	if not _ok(world):
		return
	_puff(world, star.position, Art.SALT, 10, 0.35, 30.0)
	var snap := create_tween()
	snap.tween_property(star, "position", hub, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	snap.parallel().tween_property(star, "scale", Vector2(1.0, 1.0), 0.22)
	await snap.finished
	await _pause(world, 0.2)


func _play_meteor() -> void:
	var world := _begin()
	if not _ok(world):
		return
	var start := Vector2(70, 40)
	var star := _disc(world, start, 32.0, Art.GOLD, 6)
	var tail := _box(world, start, Vector2(200, 22), Color(0.91, 0.77, 0.42, 0.85), 5)
	tail.rotation_degrees = 28.0
	var fly := create_tween()
	fly.tween_property(star, "position", Vector2(520, 250), 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fly.parallel().tween_property(tail, "position", Vector2(470, 228), 0.7)
	_puff(world, start, Art.GOLD, 10, 0.8, 24.0, Vector2(0, 10), Vector2(1, 0.45), 12.0)
	await fly.finished
	if not _ok(world):
		return
	_puff(world, star.position, Art.SALT, 14, 0.45, 40.0)
	star.visible = false
	tail.visible = false
	await _pause(world, 0.3)


func _play_footprints() -> void:
	var world := _begin()
	if not _ok(world):
		return
	var hub := _hub()
	var dest := Vector2(1000, 200)
	var paws: Array[Node2D] = []
	for i in 4:
		var t := float(i + 1) / 4.0
		var pos := hub.lerp(dest, t)
		var paw := _disc(world, pos, 28.0, Color(0.45, 0.28, 0.16, 0.0), 5)
		paw.scale = Vector2(1.0, 0.72)
		paws.append(paw)
	for paw in paws:
		if not _ok(world):
			return
		var tw := create_tween()
		tw.tween_property(paw, "modulate:a", 0.9, 0.12)
		_puff(world, paw.position, Art.GOLD, 6, 0.3, 18.0)
		await tw.finished
		if not await _pause(world, 0.12):
			return
	await _pause(world, 0.28)


func _play_road() -> void:
	var world := _begin()
	if not _ok(world):
		return
	var hub := _hub()
	_puff(world, hub, Art.GOLD, 20, 0.55, 36.0, Vector2(0, 20), Vector2(0, -1), 160.0)
	if not await _pause(world, 0.25):
		return
	_puff(world, hub + Vector2(30, 18), Art.SALT, 12, 0.45, 28.0)
	await _pause(world, 0.4)


# --- moon field --------------------------------------------------------------

func _play_furrows() -> void:
	var world := _begin()
	if not _ok(world):
		return
	var r := _spot_rect()
	var start := Vector2(r.position.x + 20.0, r.position.y + r.size.y * 0.45)
	var dust := _disc(world, start, 22.0, Art.GOLD, 5)
	var run := create_tween()
	run.tween_property(dust, "position", Vector2(r.end.x - 24.0, start.y + 18.0), 0.85).set_trans(Tween.TRANS_SINE)
	_puff(world, start, Art.GOLD, 8, 0.9, 18.0, Vector2(0, 20), Vector2(1, 0.15), 20.0)
	await run.finished
	if not _ok(world):
		return
	_puff(world, dust.position, Art.SALT, 10, 0.4, 26.0)
	await _pause(world, 0.25)


func _play_hills() -> void:
	var world := _begin()
	if not _ok(world):
		return
	var hub := _hub()
	_puff(world, hub, Art.SALT, 16, 0.9, 64.0, Vector2(0, 8), Vector2(1, 0.15), 18.0)
	if not await _pause(world, 0.35):
		return
	_puff(world, hub + Vector2(90, 12), Art.GOLD, 10, 0.6, 40.0, Vector2(0, 6), Vector2(1, 0.1), 16.0)
	await _pause(world, 0.45)


func _play_rocks() -> void:
	var world := _begin()
	if not _ok(world):
		return
	var hub := _hub()
	var rock := _disc(world, hub, 64.0, Color(0.62, 0.64, 0.68, 0.98), 5)
	rock.scale = Vector2(1.15, 0.75)
	var lift := create_tween()
	lift.tween_property(rock, "position:y", hub.y - 48.0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	lift.parallel().tween_property(rock, "rotation_degrees", 8.0, 0.4)
	await lift.finished
	if not await _pause(world, 0.45):
		return
	var drop := create_tween()
	drop.tween_property(rock, "position:y", hub.y, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	drop.parallel().tween_property(rock, "rotation_degrees", 0.0, 0.28)
	await drop.finished
	if not _ok(world):
		return
	var squash := create_tween()
	squash.tween_property(rock, "scale", Vector2(1.35, 0.55), 0.08)
	squash.tween_property(rock, "scale", Vector2(1.15, 0.75), 0.12)
	await squash.finished
	await _pause(world, 0.2)


func _play_little_crater() -> void:
	var world := _begin()
	if not _ok(world):
		return
	var hub := _hub()
	_puff(world, hub, Color(0.7, 0.68, 0.62), 12, 0.4, 32.0, Vector2(0, 40), Vector2(0, -1), 70.0)
	if not await _pause(world, 0.2):
		return
	var L := _tri(world, hub + Vector2(-16, -4), Vector2(32, 52), Color(0.93, 0.93, 0.95, 0.98), 6)
	var R := _tri(world, hub + Vector2(16, -4), Vector2(32, 52), Color(0.93, 0.93, 0.95, 0.98), 6)
	L.scale = Vector2(1, 0.1)
	R.scale = Vector2(1, 0.1)
	var peek := create_tween()
	peek.tween_property(L, "scale", Vector2(1, 1), 0.18).set_trans(Tween.TRANS_BACK)
	peek.parallel().tween_property(R, "scale", Vector2(1, 1), 0.18)
	await peek.finished
	if not await _pause(world, 0.35):
		return
	var hide := create_tween()
	hide.tween_property(L, "scale", Vector2(1, 0.05), 0.14)
	hide.parallel().tween_property(R, "scale", Vector2(1, 0.05), 0.14)
	await hide.finished
	await _pause(world, 0.15)


func _play_earth() -> void:
	var world := _begin()
	if not _ok(world):
		return
	var hub := _hub()
	var planet := _disc(world, hub, 56.0, Color(0.28, 0.48, 0.78, 0.98), 5)
	var land := _disc(world, hub + Vector2(-8, 6), 20.0, Color(0.35, 0.62, 0.38, 0.98), 6)
	var shrink := create_tween()
	shrink.tween_property(planet, "scale", Vector2(0.18, 0.18), 0.55).set_trans(Tween.TRANS_QUAD)
	shrink.parallel().tween_property(land, "scale", Vector2(0.18, 0.18), 0.55)
	shrink.parallel().tween_property(land, "position", hub, 0.55)
	await shrink.finished
	if not await _pause(world, 0.4):
		return
	var grow := create_tween()
	grow.tween_property(planet, "scale", Vector2(1.0, 1.0), 0.35).set_trans(Tween.TRANS_BACK)
	grow.parallel().tween_property(land, "scale", Vector2(1.0, 1.0), 0.35)
	grow.parallel().tween_property(land, "position", hub + Vector2(-8, 6), 0.35)
	await grow.finished
	await _pause(world, 0.2)


func _play_crater() -> void:
	var world := _begin()
	if not _ok(world):
		return
	var hub := _hub()
	var dark := _disc(world, hub, 80.0, Color(0.05, 0.06, 0.1, 0.0), 5)
	var peek := create_tween()
	peek.tween_property(dark, "modulate:a", 0.78, 0.22)
	peek.parallel().tween_property(dark, "scale", Vector2(1.15, 0.7), 0.22)
	await peek.finished
	if not await _pause(world, 0.35):
		return
	var fade := create_tween()
	fade.tween_property(dark, "modulate:a", 0.0, 0.2)
	await fade.finished
	if not _ok(world):
		return
	var mote := _disc(world, hub, 22.0, Art.GOLD, 6)
	var fly := create_tween()
	fly.tween_property(mote, "position", CAVE_MOUTH, 0.55).set_trans(Tween.TRANS_QUAD)
	_puff(world, hub, Art.GOLD, 8, 0.4, 22.0)
	await fly.finished
	if not _ok(world):
		return
	_puff(world, CAVE_MOUTH, Art.GOLD, 10, 0.4, 28.0)
	await _pause(world, 0.25)


# --- moon cave ---------------------------------------------------------------

func _play_stalactite() -> void:
	var world := _begin()
	if not _ok(world):
		return
	var hub := Vector2(_hub().x, 36.0)
	var drip := _disc(world, hub, 22.0, Art.SALT, 6)
	var fall := create_tween()
	fall.tween_property(drip, "position:y", 210.0, 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await fall.finished
	if not _ok(world):
		return
	drip.visible = false
	_puff(world, Vector2(hub.x, 210.0), Art.SALT, 12, 0.45, 32.0)
	var flash := _disc(world, Vector2(hub.x, 210.0), 28.0, Color(1, 1, 1, 0.7), 6)
	var fade := create_tween()
	fade.tween_property(flash, "modulate:a", 0.0, 0.3)
	await fade.finished


func _play_echo() -> void:
	var world := _begin()
	if not _ok(world):
		return
	var hub := _hub()
	var words: Array[Label] = []
	for i in 3:
		var l := _word(world, hub + Vector2(-10, float(i) * 8.0), "しお", Art.SALT, 56 - i * 8)
		l.modulate.a = 0.0
		words.append(l)
	for i in words.size():
		if not _ok(world):
			return
		var l: Label = words[i]
		var tw := create_tween()
		var dest := WELL.lerp(hub, 0.15) + Vector2(-40.0 * float(i), 28.0 * float(i))
		tw.tween_property(l, "modulate:a", 0.9 - float(i) * 0.22, 0.12)
		tw.parallel().tween_property(l, "position", dest, 0.7 + float(i) * 0.12)
		tw.tween_property(l, "modulate:a", 0.0, 0.35)
		if i == 0:
			await tw.finished
		else:
			await _pause(world, 0.22)
	await _pause(world, 0.45)


func _play_cave_clock() -> void:
	var world := _begin()
	if not _ok(world):
		return
	var face := Sprite2D.new()
	face.texture = load("res://assets/art/clock-face.png")
	face.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	face.centered = false
	face.position = CLOCK_FACE_POS
	face.modulate = Color(0.72, 0.82, 1.0, 0.92)
	world.add_child(face)
	var hour := _hand(world, (CLOCK_RAD * 0.58) / 115.0, 228.0)
	var minute := _hand(world, (CLOCK_RAD * 0.88) / 115.0, 48.0)
	var twitch := create_tween()
	twitch.tween_property(minute, "rotation_degrees", 62.0, 0.28).set_trans(Tween.TRANS_SINE)
	twitch.parallel().tween_property(hour, "rotation_degrees", 236.0, 0.28)
	await twitch.finished
	if not _ok(world):
		return
	var freeze := create_tween()
	freeze.tween_property(minute, "rotation_degrees", 48.0, 0.12)
	freeze.parallel().tween_property(hour, "rotation_degrees", 228.0, 0.12)
	await freeze.finished
	if not _ok(world):
		return
	_ripple(world, WELL, Color(0.7, 0.85, 1.0, 0.65), 36.0)
	if not await _pause(world, 0.25):
		return
	_ripple(world, WELL, Color(0.7, 0.85, 1.0, 0.5), 28.0)
	await _pause(world, 0.55)


func _play_cave_shelf() -> void:
	var world := _begin()
	if not _ok(world):
		return
	var hub := _hub()
	var jars: Array[Node2D] = []
	for i in 3:
		var j := _box(world, hub + Vector2(float(i - 1) * 56.0, 4.0), Vector2(36, 54), Color(0.75, 0.8, 0.9, 0.88), 5)
		jars.append(j)
	var ghost := create_tween()
	for j in jars:
		ghost.parallel().tween_property(j, "modulate:a", 0.22, 0.4)
	await ghost.finished
	if not _ok(world):
		return
	var shake := create_tween()
	for j in jars:
		shake.parallel().tween_property(j, "rotation_degrees", 8.0, 0.1)
	for j in jars:
		shake.parallel().tween_property(j, "rotation_degrees", -8.0, 0.12)
	for j in jars:
		shake.parallel().tween_property(j, "rotation_degrees", 0.0, 0.1)
	await shake.finished
	await _pause(world, 0.25)


func _play_cave_sink() -> void:
	var world := _begin()
	if not _ok(world):
		return
	var hub := _hub() + Vector2(8, -6)
	_puff(world, hub, Art.SALT, 12, 0.45, 50.0, Vector2(0, 70), Vector2(0, -1), 40.0)
	if not await _pause(world, 0.4):
		return
	var milk := _disc(world, hub, 28.0, Color(0.93, 0.95, 1.0, 0.98), 6)
	var fly := create_tween()
	fly.tween_property(milk, "position", WELL, 0.55).set_trans(Tween.TRANS_QUAD)
	await fly.finished
	if not _ok(world):
		return
	milk.visible = false
	_ripple(world, WELL, Color(0.9, 0.93, 1.0, 0.45), 18.0)
	await _pause(world, 0.35)


func _play_cave_pot() -> void:
	var world := _begin()
	if not _ok(world):
		return
	var hub := _hub()
	var lid := _disc(world, hub + Vector2(0, -36), 42.0, Color(0.18, 0.2, 0.28, 0.9), 5)
	lid.scale = Vector2(1.0, 0.42)
	var no := create_tween()
	no.tween_property(lid, "position:x", hub.x + 14.0, 0.12)
	no.tween_property(lid, "position:x", hub.x - 14.0, 0.14)
	no.tween_property(lid, "position:x", hub.x, 0.12)
	_puff(world, hub, Color(0.8, 0.85, 0.95, 0.7), 8, 0.5, 22.0)
	await no.finished
	if not _ok(world):
		return
	var spark := _disc(world, hub, 22.0, Art.GOLD, 6)
	var point := create_tween()
	point.tween_property(spark, "position", Vector2(160, 640), 0.45)
	point.parallel().tween_property(spark, "modulate:a", 0.0, 0.45)
	await point.finished


func _play_cave_window() -> void:
	var world := _begin()
	if not _ok(world):
		return
	var start := _hub()
	var moon := _disc(world, start, 60.0, Color(0.93, 0.9, 0.78, 0.96), 6)
	var drop := create_tween()
	drop.tween_property(moon, "position", WELL + Vector2(0, -40), 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await drop.finished
	if not _ok(world):
		return
	_ripple(world, WELL, Color(0.9, 0.88, 0.7, 0.4), 20.0)
	if not await _pause(world, 0.25):
		return
	var up := create_tween()
	up.tween_property(moon, "position", start, 0.45).set_trans(Tween.TRANS_SINE)
	await up.finished
	await _pause(world, 0.15)


func _play_cave_lamp() -> void:
	var world := _begin()
	if not _ok(world):
		return
	var hub := _hub()
	var glow := _disc(world, hub, 64.0, Color(0.91, 0.77, 0.42, 0.7), 4)
	var smear := create_tween()
	smear.tween_property(glow, "scale", Vector2(2.4, 1.15), 0.45).set_trans(Tween.TRANS_SINE)
	smear.parallel().tween_property(glow, "modulate:a", 0.55, 0.45)
	smear.tween_property(glow, "scale", Vector2(1.6, 1.6), 0.4)
	smear.parallel().tween_property(glow, "modulate:a", 0.25, 0.4)
	await smear.finished
	if not _ok(world):
		return
	_puff(world, hub, Color(0.75, 0.85, 1.0, 0.8), 8, 0.5, 22.0)
	await _pause(world, 0.25)


func _play_cave_jar() -> void:
	var world := _begin()
	if not _ok(world):
		return
	var hub := _hub()
	var jar := _box(world, hub, Vector2(72, 92), Color(0.7, 0.8, 0.95, 0.88), 5)
	var ghost := create_tween()
	ghost.tween_property(jar, "modulate:a", 0.12, 0.5)
	ghost.parallel().tween_property(jar, "scale", Vector2(1.08, 1.08), 0.5)
	await ghost.finished
	if not _ok(world):
		return
	_puff(world, hub, Art.SALT, 6, 0.35, 16.0)
	await _pause(world, 0.3)


func _play_cave_crystals() -> void:
	var world := _begin()
	if not _ok(world):
		return
	var hub := _hub()
	_ripple(world, hub, Color(0.8, 0.9, 1.0, 0.7), 32.0)
	_puff(world, hub, Art.SALT, 12, 0.4, 28.0)
	if not await _pause(world, 0.4):
		return
	_ripple(world, WELL, Color(0.7, 0.85, 1.0, 0.45), 20.0)
	await _pause(world, 0.5)
