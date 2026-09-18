class_name AdventureScreen
extends Control

var _art: Control
var _spots: Control
var _walker: TextureRect
var _rebuild_queued := false
var _backdrop_scene := ""

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
	if _rebuild_queued:
		return
	_rebuild_queued = true
	call_deferred("_rebuild")


func _clear_later_children(parent: Control, keep := 0) -> void:
	var kids := parent.get_children()
	for i in range(kids.size() - 1, keep - 1, -1):
		var c: Node = kids[i]
		parent.remove_child(c)
		c.free()


func _rebuild() -> void:
	_rebuild_queued = false
	if not is_inside_tree():
		return
	_walker = null
	var scene_id := GameState.scene
	if scene_id not in Hotspots.ART:
		_clear_later_children(_art, 0)
		_clear_later_children(_spots, 0)
		_backdrop_scene = ""
		return
	if _backdrop_scene != scene_id:
		_clear_later_children(_art, 0)
		Art.backdrop(_art, Hotspots.ART[scene_id])
		_backdrop_scene = scene_id
	else:
		_clear_later_children(_art, 1)
	_clear_later_children(_spots, 0)
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
				glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
			else:
				var hint := Label.new()
				hint.text = "画面をタップ、または『もどる』で畑へ"
				hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
				hint.add_theme_color_override("font_color", Art.GOLD)
				hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				Art.fill_pct(hint, 18, 58, 64, 12)
				_art.add_child(hint)


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
