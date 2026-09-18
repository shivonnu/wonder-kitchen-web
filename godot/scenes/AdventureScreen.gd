class_name AdventureScreen
extends Control

var _art: Control
var _spots: Control
var _walker: TextureRect

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	layout_mode = 1
	mouse_filter = Control.MOUSE_FILTER_PASS
	_art = Control.new()
	_art.layout_mode = 1
	_art.set_anchors_preset(Control.PRESET_FULL_RECT)
	_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_art)
	_spots = Control.new()
	_spots.layout_mode = 1
	_spots.set_anchors_preset(Control.PRESET_FULL_RECT)
	_spots.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_spots)
	GameState.flags_changed.connect(refresh)
	GameState.inventory_changed.connect(refresh)
	refresh()


func refresh() -> void:
	for c in _art.get_children():
		c.queue_free()
	for c in _spots.get_children():
		c.queue_free()
	_walker = null
	var scene_id := GameState.scene
	if scene_id not in Hotspots.ART:
		return
	Art.backdrop(_art, Hotspots.ART[scene_id])
	_draw_overlays(scene_id)
	for spot in Hotspots.visible(scene_id):
		var captured: Dictionary = spot
		Art.hotspot(
			_spots,
			str(spot["label"]),
			float(spot["x"]),
			float(spot["y"]),
			float(spot["w"]),
			float(spot["h"]),
			func() -> void: GameState.click_hotspot(captured)
		)


func _draw_overlays(scene_id: String) -> void:
	match scene_id:
		"kitchen":
			Art.sprite(_art, "res://assets/art/shion-idle.png", 32, 54, 8, 18, true, true)
			if not GameState.has_flag("lunaLeft"):
				Art.sprite(_art, "res://assets/art/luna-idle.png", 46, 52, 10, 18, true, true)
			else:
				Art.sprite(_art, "res://assets/art/icon-memo.png", 48, 56, 8, 14, false, false)
			if GameState.has_flag("saltTaken"):
				Art.sprite(_art, "res://assets/art/salt-jar-empty.png", 80, 32, 12, 20)
			if GameState.can_cook():
				var glow := Label.new()
				glow.text = "つくれる！"
				glow.add_theme_color_override("font_color", Art.GOLD)
				glow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				Art.fill_pct(glow, 36, 62, 22, 8)
				_art.add_child(glow)
		"starRoad":
			_walker = Art.sprite(_art, "res://assets/art/shion-walk.png", 14, 72, 10, 18, true, false)
			_walk_road(_walker)
		"moonField":
			if not GameState.has_item("potato"):
				Art.sprite(_art, "res://assets/art/potato.png", 10, 42, 16, 22, false, true)
			if not GameState.has_item("onion"):
				Art.sprite(_art, "res://assets/art/onion.png", 32, 40, 14, 20, false, true)
		"moonCave":
			if not GameState.has_item("moonMilk"):
				Art.sprite(_art, "res://assets/art/moon-well.png", 36, 46, 26, 32, false, true)


func _walk_road(r: TextureRect) -> void:
	var tw := r.create_tween()
	tw.set_loops()
	tw.set_trans(Tween.TRANS_LINEAR)
	tw.tween_callback(func() -> void: Art.fill_pct(r, 14, 72, 10, 18))
	tw.tween_method(func(t: float) -> void:
		Art.fill_pct(r, lerpf(14, 48, t), lerpf(72, 42, t), 10, 18)
	, 0.0, 1.0, 1.2)
	tw.tween_method(func(t: float) -> void:
		Art.fill_pct(r, lerpf(48, 66, t), lerpf(42, 22, t), 10, 18)
	, 0.0, 1.0, 1.2)
