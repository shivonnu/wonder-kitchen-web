class_name GizmoFx
extends Control

var busy := false
var _layer: Control

# Kitchen.png 1280x720 clock crop (241,12)-(421,236), hub (331,110).
const CLOCK_BOX := [18.828, 1.667, 14.0625, 31.111]
const CLOCK_HUB := Vector2(0.5, 0.4375)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	layout_mode = 1
	_layer = Control.new()
	_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.layout_mode = 1
	_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_layer)


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


func _clear_layer() -> void:
	if _layer == null:
		return
	for c in _layer.get_children():
		_layer.remove_child(c)
		c.free()


func _play_clock() -> void:
	_clear_layer()
	Art.boot()
	var box := Control.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	Art.fill_pct(box, CLOCK_BOX[0], CLOCK_BOX[1], CLOCK_BOX[2], CLOCK_BOX[3])
	_layer.add_child(box)

	var face := TextureRect.new()
	face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	face.stretch_mode = TextureRect.STRETCH_SCALE
	face.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	face.texture = load("res://assets/art/clock-face.png")
	face.layout_mode = 1
	face.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.add_child(face)

	await get_tree().process_frame
	if not is_instance_valid(box):
		return

	var hub := Vector2(box.size.x * CLOCK_HUB.x, box.size.y * CLOCK_HUB.y)
	var rad := box.size.x * (78.0 / 180.0)
	var hour := _make_hand(box, hub, 0.42, -12.0)
	var minute := _make_hand(box, hub, 0.72, 48.0)
	var door := _make_sprite(box, "res://assets/art/clock-door.png", Vector2(hub.x, hub.y - rad + 6.0), 0.55)
	door.offset = Vector2(0, -door.texture.get_height() * 0.45)
	door.visible = false
	var bird := _make_sprite(box, "res://assets/art/clock-bird.png", Vector2(hub.x, hub.y - rad + 8.0), 0.42)
	bird.visible = false
	bird.z_index = 3

	var spin := create_tween()
	spin.set_trans(Tween.TRANS_QUAD)
	spin.set_ease(Tween.EASE_IN)
	spin.tween_property(minute, "rotation_degrees", minute.rotation_degrees + 1260.0, 1.35)
	spin.parallel().tween_property(hour, "rotation_degrees", hour.rotation_degrees + 700.0, 1.35)
	await spin.finished
	if not is_instance_valid(box):
		return

	door.visible = true
	door.rotation_degrees = 0.0
	var open_tw := create_tween()
	open_tw.tween_property(door, "rotation_degrees", -78.0, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await open_tw.finished
	if not is_instance_valid(box):
		return

	bird.visible = true
	bird.position = Vector2(hub.x + 4.0, hub.y - rad + 10.0)
	bird.scale = Vector2(0.18, 0.18)
	var pop := create_tween()
	pop.set_trans(Tween.TRANS_BACK)
	pop.set_ease(Tween.EASE_OUT)
	pop.tween_property(bird, "position", Vector2(hub.x + 10.0, hub.y - rad - 18.0), 0.28)
	pop.parallel().tween_property(bird, "scale", Vector2(0.42, 0.42), 0.28)
	await pop.finished
	if not is_instance_valid(box):
		return

	Art.spark_at(self, bird.global_position)
	var bob := create_tween()
	bob.tween_property(bird, "position:y", bird.position.y - 6.0, 0.12)
	bob.tween_property(bird, "position:y", bird.position.y + 2.0, 0.14)
	await bob.finished
	await get_tree().create_timer(0.28).timeout
	if not is_instance_valid(box):
		return

	var back := create_tween()
	back.tween_property(bird, "position", Vector2(hub.x + 4.0, hub.y - rad + 10.0), 0.16)
	back.parallel().tween_property(bird, "scale", Vector2(0.16, 0.16), 0.16)
	back.tween_property(door, "rotation_degrees", 0.0, 0.12)
	await back.finished
	if not is_instance_valid(box):
		return

	bird.visible = false
	door.visible = false
	hour.rotation_degrees = -12.0
	minute.rotation_degrees = 48.0
	await get_tree().create_timer(0.2).timeout
	_clear_layer()


func _make_hand(parent: Control, hub: Vector2, length_scale: float, degrees: float) -> Sprite2D:
	var s := _make_sprite(parent, "res://assets/art/clock-hand.png", hub, length_scale)
	if s.texture:
		s.offset = Vector2(0.0, -s.texture.get_height() * 0.40)
	s.rotation_degrees = degrees
	s.z_index = 2
	return s


func _make_sprite(parent: Control, path: String, pos: Vector2, sc: float) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = load(path)
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.material = Art.chroma
	s.centered = true
	s.position = pos
	s.scale = Vector2(sc, sc)
	parent.add_child(s)
	return s
