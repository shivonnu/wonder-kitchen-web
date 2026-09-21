class_name GizmoFx
extends Control

var busy := false

# kitchen.png is 1280x720 and fills the 16:9 stage.
const KITCHEN := Vector2(1280.0, 720.0)
const CLOCK_FACE_POS := Vector2(241, 12)
const CLOCK_HUB := Vector2(331, 110)
const CLOCK_RAD := 78.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	layout_mode = 1


func play(kind: String) -> void:
	if busy:
		return
	busy = true
	match kind:
		"clock":
			await _play_clock()
		_:
			pass
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
	world.scale = Vector2(stage.x / KITCHEN.x, stage.y / KITCHEN.y)
	add_child(world)
	return world


func _play_clock() -> void:
	Art.boot()
	var host := get_parent() as Control
	var tries := 0
	while host != null and host.size.x < 8.0 and tries < 10:
		await get_tree().process_frame
		tries += 1
	var world := _world()
	if not is_instance_valid(world):
		return

	var face := Sprite2D.new()
	face.texture = load("res://assets/art/clock-face.png")
	face.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	face.centered = false
	face.position = CLOCK_FACE_POS
	world.add_child(face)

	# Hand texture tip sits ~115px from the hub at scale 1. Keep tips inside the ring.
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

	await get_tree().create_timer(0.08).timeout
	if not is_instance_valid(world):
		return

	var spin := create_tween()
	spin.set_trans(Tween.TRANS_QUAD)
	spin.set_ease(Tween.EASE_IN)
	spin.tween_property(minute, "rotation_degrees", minute.rotation_degrees + 1620.0, 1.65)
	spin.parallel().tween_property(hour, "rotation_degrees", hour.rotation_degrees + 880.0, 1.65)
	await spin.finished
	if not is_instance_valid(world):
		return

	door.visible = true
	var open_tw := create_tween()
	open_tw.tween_property(door, "rotation_degrees", -82.0, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await open_tw.finished
	if not is_instance_valid(world):
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
	if not is_instance_valid(world):
		return

	Art.spark_at(self, bird.to_global(Vector2.ZERO))
	var bob := create_tween()
	bob.tween_property(bird, "position:y", perch.y - 6.0, 0.12)
	bob.tween_property(bird, "position:y", perch.y + 2.0, 0.16)
	await bob.finished
	await get_tree().create_timer(0.32).timeout
	if not is_instance_valid(world):
		return

	var back := create_tween()
	back.tween_property(bird, "position", hatch, 0.16)
	back.parallel().tween_property(bird, "scale", Vector2(0.14, 0.14), 0.16)
	back.tween_property(door, "rotation_degrees", 0.0, 0.12)
	await back.finished
	if not is_instance_valid(world):
		return

	bird.visible = false
	door.visible = false
	hour.rotation_degrees = 228.0
	minute.rotation_degrees = 48.0
	await get_tree().create_timer(0.22).timeout
	_clear()


func _hand(world: Node2D, sc: float, degrees: float) -> Sprite2D:
	var s := _spr(world, "res://assets/art/clock-hand.png", CLOCK_HUB, sc)
	if s.texture:
		s.offset = Vector2(0.0, -s.texture.get_height() * 0.40)
	s.rotation_degrees = degrees
	s.z_index = 2
	return s


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
