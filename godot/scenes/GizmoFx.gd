class_name GizmoFx
extends Control

var busy := false
var _spot: Dictionary = {}

const STAGE := Vector2(1280.0, 720.0)
const CLOCK_FACE_POS := Vector2(241, 12)
const CLOCK_HUB := Vector2(331, 110)
const CLOCK_RAD := 78.0
const WELL := Vector2(627, 446)
const CAVE_MOUTH := Vector2(1126, 280)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
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
	world.z_index = 8
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


func _disc(world: Node2D, pos: Vector2, r: float, color: Color, z := 4) -> Polygon2D:
	var p := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in 18:
		var a := TAU * float(i) / 18.0
		pts.append(Vector2(cos(a), sin(a)) * r)
	p.polygon = pts
	p.color = color
	p.position = pos
	p.z_index = z
	world.add_child(p)
	return p


func _box(world: Node2D, pos: Vector2, size: Vector2, color: Color, z := 4) -> Polygon2D:
	var p := Polygon2D.new()
	var hx := size.x * 0.5
	var hy := size.y * 0.5
	p.polygon = PackedVector2Array([
		Vector2(-hx, -hy), Vector2(hx, -hy), Vector2(hx, hy), Vector2(-hx, hy)
	])
	p.color = color
	p.position = pos
	p.z_index = z
	world.add_child(p)
	return p


func _tri(world: Node2D, pos: Vector2, size: Vector2, color: Color, z := 4) -> Polygon2D:
	var p := Polygon2D.new()
	p.polygon = PackedVector2Array([
		Vector2(0.0, -size.y), Vector2(size.x * 0.5, 0.0), Vector2(-size.x * 0.5, 0.0)
	])
	p.color = color
	p.position = pos
	p.z_index = z
	world.add_child(p)
	return p


func _word(world: Node2D, pos: Vector2, text: String, color: Color, px := 22) -> Label:
	var l := Label.new()
	l.text = text
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_color_override("font_color", color)
	l.add_theme_font_size_override("font_size", px)
	if Art.font:
		l.add_theme_font_override("font", Art.font)
	l.position = pos
	l.z_index = 7
	world.add_child(l)
	return l


func _puff(world: Node2D, pos: Vector2, color: Color, n := 12, life := 0.45, vel := 52.0, grav := Vector2(0, 36), dir := Vector2(0, -1), spread := 180.0) -> void:
	if not _ok(world):
		return
	var p := CPUParticles2D.new()
	p.z_index = 6
	p.position = pos
	p.emitting = false
	p.one_shot = true
	p.amount = n
	p.lifetime = life
	p.explosiveness = 0.9
	p.texture = load("res://assets/art/sparkle.png")
	p.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	p.direction = dir
	p.spread = spread
	p.gravity = grav
	p.initial_velocity_min = vel * 0.35
	p.initial_velocity_max = vel
	p.scale_amount_min = 0.14
	p.scale_amount_max = 0.4
	p.color = color
	world.add_child(p)
	p.restart()
	p.emitting = true
	p.finished.connect(p.queue_free)


func _spr(world: Node2D, path: String, pos: Vector2, sc: float) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = load(path)
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.material = Art.chroma
	s.centered = true
	s.position = pos
	s.scale = Vector2(sc, sc)
	world.add_child(s)
	return s


func _ripple(world: Node2D, pos: Vector2, color: Color, start_r := 16.0) -> void:
	var ring := _disc(world, pos, start_r, color, 5)
	ring.modulate.a = 0.7
	var tw := create_tween()
	tw.tween_property(ring, "scale", Vector2(3.4, 3.4), 0.7).set_trans(Tween.TRANS_QUAD)
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
	var glow := _disc(world, hub, 22.0, Color(0.91, 0.77, 0.42, 0.22), 3)
	glow.scale = Vector2(0.4, 0.4)
	var grow := create_tween()
	grow.tween_property(glow, "scale", Vector2(2.2, 2.2), 0.55).set_trans(Tween.TRANS_SINE)
	grow.parallel().tween_property(glow, "color:a", 0.55, 0.55)
	_puff(world, hub, Art.GOLD, 10, 0.4, 36.0)
	if not await _pause(world, 0.5):
		return
	var drip := _disc(world, hub + Vector2(0, 18), 7.0, Art.GOLD, 5)
	var fall := create_tween()
	fall.tween_property(drip, "position:y", hub.y + 92.0, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fall.parallel().tween_property(drip, "scale", Vector2(0.6, 1.3), 0.55)
	await fall.finished
	if not _ok(world):
		return
	drip.visible = false
	_puff(world, Vector2(hub.x, hub.y + 92.0), Art.GOLD, 14, 0.5, 48.0)
	await _pause(world, 0.35)


func _play_sink() -> void:
	var world := _world()
	if not _ok(world):
		return
	var hub := _hub() + Vector2(8, -8)
	_puff(world, hub, Art.SALT, 16, 0.5, 70.0, Vector2(0, 80), Vector2(0, -1), 50.0)
	if not await _pause(world, 0.45):
		return
	_puff(world, hub + Vector2(10, 6), Color(0.55, 0.78, 1.0, 1), 12, 0.4, 58.0, Vector2(0, 90), Vector2(0, -1), 40.0)
	if not await _pause(world, 0.35):
		return
	var ice := _box(world, hub + Vector2(6, 18), Vector2(18, 18), Color(0.78, 0.92, 1.0, 0.95), 6)
	ice.rotation_degrees = 45.0
	ice.scale = Vector2(0.2, 0.2)
	var pop := create_tween()
	pop.tween_property(ice, "scale", Vector2(1.0, 1.0), 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await pop.finished
	if not _ok(world):
		return
	_puff(world, ice.position, Art.SALT, 8, 0.4, 28.0)
	if not await _pause(world, 0.35):
		return
	var fade := create_tween()
	fade.tween_property(ice, "modulate:a", 0.0, 0.28)
	await fade.finished


func _play_shelf() -> void:
	var world := _world()
	if not _ok(world):
		return
	var hub := _hub()
	var jars: Array[Polygon2D] = []
	var cols := [Color(0.85, 0.8, 0.7, 0.85), Color(0.7, 0.55, 0.4, 0.85), Color(0.91, 0.77, 0.42, 0.95)]
	for i in 3:
		var j := _box(world, hub + Vector2(float(i - 1) * 36.0, 4.0), Vector2(18, 28), cols[i], 5)
		jars.append(j)
	var base: Array[float] = []
	for j in jars:
		base.append(j.position.x)
	for _k in 3:
		var shake := create_tween()
		for i in jars.size():
			shake.parallel().tween_property(jars[i], "position:x", base[i] + 7.0, 0.08)
		await shake.finished
		if not _ok(world):
			return
		shake = create_tween()
		for i in jars.size():
			shake.parallel().tween_property(jars[i], "position:x", base[i] - 7.0, 0.08)
		await shake.finished
		if not _ok(world):
			return
		shake = create_tween()
		for i in jars.size():
			shake.parallel().tween_property(jars[i], "position:x", base[i], 0.08)
		await shake.finished
		if not _ok(world):
			return
	if not _ok(world):
		return
	var hide := create_tween()
	hide.tween_property(jars[0], "modulate:a", 0.0, 0.28)
	hide.parallel().tween_property(jars[1], "modulate:a", 0.0, 0.28)
	await hide.finished
	if not _ok(world):
		return
	_puff(world, jars[2].position, Art.GOLD, 10, 0.45, 36.0)
	await _pause(world, 0.4)


func _play_floor_crystal() -> void:
	var world := _world()
	if not _ok(world):
		return
	var hub := _hub()
	_ripple(world, hub, Color(0.85, 0.92, 1.0, 0.55), 14.0)
	_puff(world, hub, Art.SALT, 14, 0.5, 40.0)
	if not await _pause(world, 0.45):
		return
	var star := _disc(world, Vector2(920, 70), 8.0, Art.GOLD, 6)
	star.scale = Vector2(0.2, 0.2)
	var tw := create_tween()
	tw.tween_property(star, "scale", Vector2(1.8, 1.8), 0.28).set_trans(Tween.TRANS_BACK)
	tw.tween_property(star, "scale", Vector2(0.9, 0.9), 0.2)
	tw.tween_property(star, "modulate:a", 0.0, 0.4)
	await tw.finished


func _play_wall_stars() -> void:
	var world := _world()
	if not _ok(world):
		return
	var hub := _hub()
	var bits: Array[Polygon2D] = []
	for i in 5:
		var a := TAU * float(i) / 5.0
		var p := _disc(world, hub + Vector2(cos(a), sin(a)) * 48.0, 5.0, Art.GOLD, 5)
		bits.append(p)
	var gather := create_tween()
	for p in bits:
		gather.parallel().tween_property(p, "position", hub, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await gather.finished
	if not _ok(world):
		return
	_puff(world, hub, Art.SALT, 16, 0.5, 44.0)
	var flash := _disc(world, hub, 28.0, Color(1, 1, 1, 0.55), 6)
	var fade := create_tween()
	fade.tween_property(flash, "modulate:a", 0.0, 0.35)
	fade.parallel().tween_property(flash, "scale", Vector2(1.8, 1.8), 0.35)
	await fade.finished


func _play_table() -> void:
	var world := _world()
	if not _ok(world):
		return
	var hub := _hub()
	var board := _box(world, hub, Vector2(92, 48), Color(0.55, 0.38, 0.22, 0.0), 5)
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
	var world := _world()
	if not _ok(world):
		return
	var hub := _hub()
	var luna := _spr(world, "res://assets/art/luna-idle.png", hub + Vector2(0, 6), 0.55)
	if luna.texture:
		var atlas := AtlasTexture.new()
		atlas.atlas = luna.texture
		atlas.region = Rect2(0, 0, luna.texture.get_width() * 0.5, luna.texture.get_height())
		luna.texture = atlas
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
	var world := _world()
	if not _ok(world):
		return
	var hub := _hub()
	var lid := _disc(world, hub + Vector2(0, -36), 28.0, Color(0.18, 0.2, 0.28, 0.92), 5)
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
	var world := _world()
	if not _ok(world):
		return
	var hub := _hub()
	var jar := _spr(world, "res://assets/art/icon-salt.png", hub, 0.7)
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
	_puff(world, hub + Vector2(0, 16), Art.SALT, 4, 0.3, 16.0)
	await _pause(world, 0.3)


func _play_memo() -> void:
	var world := _world()
	if not _ok(world):
		return
	var hub := _hub()
	var paper := _spr(world, "res://assets/art/icon-memo.png", hub, 0.85)
	var flip := create_tween()
	flip.tween_property(paper, "scale:x", 0.05, 0.16)
	flip.tween_property(paper, "scale:x", 0.85, 0.16)
	flip.tween_property(paper, "scale:x", 0.05, 0.14)
	flip.tween_property(paper, "scale:x", 0.85, 0.16)
	await flip.finished
	if not _ok(world):
		return
	_puff(world, hub, Art.GOLD, 8, 0.35, 24.0)
	await _pause(world, 0.25)


# --- star road ---------------------------------------------------------------

func _play_clouds() -> void:
	var world := _world()
	if not _ok(world):
		return
	var hub := _hub()
	_puff(world, hub, Art.SALT, 18, 0.7, 36.0, Vector2(0, 70), Vector2(0, 1), 50.0)
	if not await _pause(world, 0.55):
		return
	_puff(world, hub + Vector2(0, 50), Art.GOLD, 12, 0.6, 40.0, Vector2(0, -20), Vector2(0, -1), 40.0)
	await _pause(world, 0.45)


func _play_near_stars() -> void:
	var world := _world()
	if not _ok(world):
		return
	var hub := _hub()
	var star := _disc(world, hub, 10.0, Art.GOLD, 6)
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
	var world := _world()
	if not _ok(world):
		return
	var start := Vector2(70, 40)
	var star := _disc(world, start, 11.0, Art.GOLD, 6)
	var tail := _box(world, start, Vector2(90, 8), Color(0.91, 0.77, 0.42, 0.55), 5)
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
	var world := _world()
	if not _ok(world):
		return
	var hub := _hub()
	var dest := Vector2(1000, 200)
	var paws: Array[Polygon2D] = []
	for i in 4:
		var t := float(i + 1) / 4.0
		var pos := hub.lerp(dest, t)
		var paw := _disc(world, pos, 11.0, Color(0.45, 0.28, 0.16, 0.0), 5)
		paw.scale = Vector2(1.0, 0.72)
		paws.append(paw)
	for paw in paws:
		if not _ok(world):
			return
		var tw := create_tween()
		tw.tween_property(paw, "color:a", 0.9, 0.12)
		_puff(world, paw.position, Art.GOLD, 6, 0.3, 18.0)
		await tw.finished
		if not await _pause(world, 0.12):
			return
	await _pause(world, 0.28)


func _play_road() -> void:
	var world := _world()
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
	var world := _world()
	if not _ok(world):
		return
	var r := _spot_rect()
	var start := Vector2(r.position.x + 20.0, r.position.y + r.size.y * 0.45)
	var dust := _disc(world, start, 6.0, Art.GOLD, 5)
	var run := create_tween()
	run.tween_property(dust, "position", Vector2(r.end.x - 24.0, start.y + 18.0), 0.85).set_trans(Tween.TRANS_SINE)
	_puff(world, start, Art.GOLD, 8, 0.9, 18.0, Vector2(0, 20), Vector2(1, 0.15), 20.0)
	await run.finished
	if not _ok(world):
		return
	_puff(world, dust.position, Art.SALT, 10, 0.4, 26.0)
	await _pause(world, 0.25)


func _play_hills() -> void:
	var world := _world()
	if not _ok(world):
		return
	var hub := _hub()
	_puff(world, hub, Art.SALT, 16, 0.9, 64.0, Vector2(0, 8), Vector2(1, 0.15), 18.0)
	if not await _pause(world, 0.35):
		return
	_puff(world, hub + Vector2(90, 12), Art.GOLD, 10, 0.6, 40.0, Vector2(0, 6), Vector2(1, 0.1), 16.0)
	await _pause(world, 0.45)


func _play_rocks() -> void:
	var world := _world()
	if not _ok(world):
		return
	var hub := _hub()
	var rock := _disc(world, hub, 26.0, Color(0.62, 0.64, 0.68, 0.92), 5)
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
	var world := _world()
	if not _ok(world):
		return
	var hub := _hub()
	_puff(world, hub, Color(0.7, 0.68, 0.62), 12, 0.4, 32.0, Vector2(0, 40), Vector2(0, -1), 70.0)
	if not await _pause(world, 0.2):
		return
	var L := _tri(world, hub + Vector2(-8, -4), Vector2(14, 22), Color(0.93, 0.93, 0.95, 0.95), 6)
	var R := _tri(world, hub + Vector2(8, -4), Vector2(14, 22), Color(0.93, 0.93, 0.95, 0.95), 6)
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
	var world := _world()
	if not _ok(world):
		return
	var hub := _hub()
	var planet := _disc(world, hub, 22.0, Color(0.28, 0.48, 0.78, 0.95), 5)
	var land := _disc(world, hub + Vector2(-4, 2), 8.0, Color(0.35, 0.62, 0.38, 0.95), 6)
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
	grow.parallel().tween_property(land, "position", hub + Vector2(-4, 2), 0.35)
	await grow.finished
	await _pause(world, 0.2)


func _play_crater() -> void:
	var world := _world()
	if not _ok(world):
		return
	var hub := _hub()
	var dark := _disc(world, hub, 40.0, Color(0.05, 0.06, 0.1, 0.0), 5)
	var peek := create_tween()
	peek.tween_property(dark, "color:a", 0.72, 0.22)
	peek.parallel().tween_property(dark, "scale", Vector2(1.15, 0.7), 0.22)
	await peek.finished
	if not await _pause(world, 0.35):
		return
	var fade := create_tween()
	fade.tween_property(dark, "color:a", 0.0, 0.2)
	await fade.finished
	if not _ok(world):
		return
	var mote := _disc(world, hub, 7.0, Art.GOLD, 6)
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
	var world := _world()
	if not _ok(world):
		return
	var hub := Vector2(_hub().x, 36.0)
	var drip := _disc(world, hub, 6.0, Art.SALT, 6)
	var fall := create_tween()
	fall.tween_property(drip, "position:y", 210.0, 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await fall.finished
	if not _ok(world):
		return
	drip.visible = false
	_puff(world, Vector2(hub.x, 210.0), Art.SALT, 12, 0.45, 32.0)
	var flash := _disc(world, Vector2(hub.x, 210.0), 16.0, Color(1, 1, 1, 0.5), 6)
	var fade := create_tween()
	fade.tween_property(flash, "modulate:a", 0.0, 0.3)
	await fade.finished


func _play_echo() -> void:
	var world := _world()
	if not _ok(world):
		return
	var hub := _hub()
	var words: Array[Label] = []
	for i in 3:
		var l := _word(world, hub + Vector2(-10, float(i) * 8.0), "しお", Art.SALT, 26 - i * 4)
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
	var world := _world()
	if not _ok(world):
		return
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
	_ripple(world, WELL, Color(0.7, 0.85, 1.0, 0.5), 22.0)
	if not await _pause(world, 0.25):
		return
	_ripple(world, WELL, Color(0.7, 0.85, 1.0, 0.35), 16.0)
	await _pause(world, 0.55)


func _play_cave_shelf() -> void:
	var world := _world()
	if not _ok(world):
		return
	var hub := _hub()
	var jars: Array[Polygon2D] = []
	for i in 3:
		var j := _box(world, hub + Vector2(float(i - 1) * 34.0, 4.0), Vector2(16, 26), Color(0.75, 0.8, 0.9, 0.55), 5)
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
	var world := _world()
	if not _ok(world):
		return
	var hub := _hub() + Vector2(8, -6)
	_puff(world, hub, Art.SALT, 12, 0.45, 50.0, Vector2(0, 70), Vector2(0, -1), 40.0)
	if not await _pause(world, 0.4):
		return
	var milk := _disc(world, hub, 8.0, Color(0.93, 0.95, 1.0, 0.95), 6)
	var fly := create_tween()
	fly.tween_property(milk, "position", WELL, 0.55).set_trans(Tween.TRANS_QUAD)
	await fly.finished
	if not _ok(world):
		return
	milk.visible = false
	_ripple(world, WELL, Color(0.9, 0.93, 1.0, 0.45), 18.0)
	await _pause(world, 0.35)


func _play_cave_pot() -> void:
	var world := _world()
	if not _ok(world):
		return
	var hub := _hub()
	var lid := _disc(world, hub + Vector2(0, -36), 28.0, Color(0.18, 0.2, 0.28, 0.9), 5)
	lid.scale = Vector2(1.0, 0.42)
	var no := create_tween()
	no.tween_property(lid, "position:x", hub.x + 14.0, 0.12)
	no.tween_property(lid, "position:x", hub.x - 14.0, 0.14)
	no.tween_property(lid, "position:x", hub.x, 0.12)
	_puff(world, hub, Color(0.8, 0.85, 0.95, 0.7), 8, 0.5, 22.0)
	await no.finished
	if not _ok(world):
		return
	var spark := _disc(world, hub, 6.0, Art.GOLD, 6)
	var point := create_tween()
	point.tween_property(spark, "position", Vector2(160, 640), 0.45)
	point.parallel().tween_property(spark, "modulate:a", 0.0, 0.45)
	await point.finished


func _play_cave_window() -> void:
	var world := _world()
	if not _ok(world):
		return
	var start := _hub()
	var moon := _disc(world, start, 28.0, Color(0.93, 0.9, 0.78, 0.92), 6)
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
	var world := _world()
	if not _ok(world):
		return
	var hub := _hub()
	var glow := _disc(world, hub, 26.0, Color(0.91, 0.77, 0.42, 0.4), 4)
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
	var world := _world()
	if not _ok(world):
		return
	var hub := _hub()
	var jar := _box(world, hub, Vector2(36, 48), Color(0.7, 0.8, 0.95, 0.55), 5)
	var ghost := create_tween()
	ghost.tween_property(jar, "modulate:a", 0.12, 0.5)
	ghost.parallel().tween_property(jar, "scale", Vector2(1.08, 1.08), 0.5)
	await ghost.finished
	if not _ok(world):
		return
	_puff(world, hub, Art.SALT, 6, 0.35, 16.0)
	await _pause(world, 0.3)


func _play_cave_crystals() -> void:
	var world := _world()
	if not _ok(world):
		return
	var hub := _hub()
	_ripple(world, hub, Color(0.8, 0.9, 1.0, 0.55), 14.0)
	_puff(world, hub, Art.SALT, 12, 0.4, 28.0)
	if not await _pause(world, 0.4):
		return
	_ripple(world, WELL, Color(0.7, 0.85, 1.0, 0.45), 20.0)
	await _pause(world, 0.5)
