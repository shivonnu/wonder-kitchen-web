class_name AdventureScreen
extends Control

const MISS_LINES := {
	"kitchen": [
		"そこは、ふつうの夜の空気。時計、窓、ルナ、壺……気になったらタップ。",
		"指先で、星くずがちょっと光った。別の場所も触ってみて。",
		"テーブルのまわりを、もうすこし探してみて。",
	],
	"starRoad": [
		"雲のあいだを、ながれ星がすり抜けていった。",
		"足跡か、光の扉をたどると、月のうら側だよ。",
		"踏むたび、靴の裏がきらきらする。",
	],
	"moonField": [
		"月の土は、ふわっと軽い。いも、たまねぎ、洞窟を探してみて。",
		"風が、塩の匂いを運んできた。",
		"丘の向こうまで、今夜は歩かなくていいよ。",
	],
	"moonCave": [
		"井戸と、鍾乳石と、こだま。触ると、何か言うよ。",
		"洞窟の空気が、牛乳みたいに白い。",
		"星しおは、ここじゃなくてキッチンの壺だよ。",
	],
}

var _art: Control
var _spots: Control
var _gizmo: GizmoFx
var _fx: Node2D
var _water: CPUParticles2D
var _walker: TextureRect
var _rebuild_queued := false
var _backdrop_scene := ""
var _overlay_sig := ""
var _miss_i := 0
var _last_miss_msec := 0
var _held_fx: TextureRect
var _held_water: TextureRect


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	layout_mode = 1
	mouse_filter = Control.MOUSE_FILTER_PASS
	_art = Control.new()
	_art.layout_mode = 1
	_art.set_anchors_preset(Control.PRESET_FULL_RECT)
	_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_art)
	_gizmo = GizmoFx.new()
	_gizmo.z_index = 60
	_gizmo.z_as_relative = false
	add_child(_gizmo)
	_spots = Control.new()
	_spots.layout_mode = 1
	_spots.set_anchors_preset(Control.PRESET_FULL_RECT)
	_spots.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_spots)
	_fx = Node2D.new()
	_fx.z_index = 40
	add_child(_fx)
	_water = CPUParticles2D.new()
	_water.emitting = false
	_water.amount = 40
	_water.lifetime = 0.7
	_water.direction = Vector2(0, 1)
	_water.spread = 8
	_water.initial_velocity_min = 40
	_water.initial_velocity_max = 90
	_water.gravity = Vector2(0, 80)
	_water.color = Color(0.72, 0.85, 1.0, 0.85)
	_fx.add_child(_water)
	resized.connect(_place_kitchen_water)
	GameState.flags_changed.connect(refresh)
	GameState.inventory_changed.connect(refresh)
	GameState.hand_changed.connect(refresh)
	GameState.pot_changed.connect(refresh)
	_held_fx = TextureRect.new()
	_held_fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_held_fx.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_held_fx.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_held_fx.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_held_fx.material = Art.chroma
	_held_fx.size = Vector2(140, 92)
	_held_fx.z_index = 80
	_held_fx.visible = false
	add_child(_held_fx)
	_held_water = TextureRect.new()
	_held_water.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_held_water.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_held_water.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_held_water.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_held_water.material = Art.chroma
	_held_water.size = Vector2(88, 18)
	_held_water.z_index = 81
	_held_water.visible = false
	add_child(_held_water)
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
		_overlay_sig = ""
		return
	if _backdrop_scene != scene_id:
		_clear_later_children(_art, 0)
		Art.backdrop(_art, Hotspots.ART[scene_id])
		_backdrop_scene = scene_id
		_overlay_sig = ""
	var sig := _current_overlay_sig(scene_id)
	if _overlay_sig != sig:
		_clear_later_children(_art, 1)
		_draw_overlays(scene_id)
		_overlay_sig = sig
	_clear_later_children(_spots, 0)
	_place_kitchen_water()
	for spot in Hotspots.visible(scene_id):
		var captured: Dictionary = spot
		Art.hotspot(
			_spots,
			str(spot["label"]),
			float(spot["x"]),
			float(spot["y"]),
			float(spot["w"]),
			float(spot["h"]),
			func() -> void: _click_spot(captured),
			_fx
		)


func _current_overlay_sig(scene_id: String) -> String:
	return "|".join([
		scene_id,
		str(GameState.has_flag("lunaLeft")),
		str(GameState.has_flag("kitchenFaucet")),
		str(GameState.has_item("potato")),
		str(GameState.has_item("onion")),
		str(GameState.has_item("moonMilk")),
		str(GameState.can_cook()),
		str(GameState.hand),
		str(GameState.pot_place),
		str(GameState.pot_water),
	])


func _draw_overlays(scene_id: String) -> void:
	match scene_id:
		"kitchen":
			Hotspots.draw_pot(_art, "kitchen")
			if GameState.has_flag("kitchenFaucet"):
				Art.sprite(_art, "res://assets/art/water-stream.png", 7.4, 40.5, 5.2, 22.0, false, false)
			var pepper := Art.sprite(_art, "res://assets/art/pepper-jar.png", 16.17, 22.64, 3.13, 9.03, false, false)
			pepper.name = "pepperJar"
			var salt := Art.sprite(_art, "res://assets/art/salt-jar.png", 85.86, 40.0, 6.95, 15.42, false, false)
			salt.name = "kitchenSaltJar"
			var shion := Art.sprite(_art, "res://assets/art/shion-idle.png", 32, 54, 8, 18, true, true)
			shion.name = "kitchenShion"
			if not GameState.has_flag("lunaLeft"):
				Art.sprite(_art, "res://assets/art/luna-idle.png", 46, 52, 10, 18, true, true)
			else:
				var memo := Art.sprite(_art, "res://assets/art/icon-memo.png", 48, 56, 8, 14, false, false)
				memo.name = "kitchenMemo"
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


func set_kitchen_actors_visible(on: bool) -> void:
	for n in ["kitchenShion", "pepperJar"]:
		var c := _art.get_node_or_null(n)
		if c:
			c.visible = on


func set_kitchen_salt_visible(on: bool) -> void:
	var c := _art.get_node_or_null("kitchenSaltJar")
	if c:
		c.visible = on


func set_kitchen_memo_visible(on: bool) -> void:
	var c := _art.get_node_or_null("kitchenMemo")
	if c:
		c.visible = on


func _click_spot(spot: Dictionary) -> void:
	var id := str(spot.get("id", ""))
	if id == "pot" or id == "sinkBasin" or (id == "sink" and GameState.hand == "pot"):
		_on_kitchen_pot_spot(id)
		return
	var fx := str(spot.get("fx", ""))
	if fx != "" and _gizmo != null:
		if _gizmo.busy:
			return
		await _gizmo.play(fx, spot)
		if not is_inside_tree():
			return
		if id == "sink":
			_kitchen_try_fill()
			return
	GameState.click_hotspot(spot)


func _on_kitchen_pot_spot(id: String) -> void:
	if GameState.scene != "kitchen":
		return
	var hand := GameState.hand
	if hand == "pot":
		if id == "pot":
			GameState.set_pot_place("stove")
			GameState.clear_hand()
			if GameState.pot_water:
				GameState.say("しおん", "コンロに戻したよ。水は入ったまま。")
			else:
				GameState.say("しおん", "まだ何も入っていない。材料がそろったら、ここで煮よう。")
		else:
			GameState.set_pot_place("sink")
			GameState.clear_hand()
			if GameState.has_flag("kitchenFaucet"):
				GameState.fill_pot_in_sink(true)
				GameState.say("しおん", "白い星くずが、鍋にたまっていった。")
			else:
				GameState.say("しおん", "流しに置いたよ。蛇口をひねると、水が貯まる。")
		return
	if hand != "":
		GameState.say("しおん", "今は%sを持っているよ。" % Hotspots.HAND_NAMES.get(hand, hand))
		return
	if id == "pot":
		if GameState.pot_place != "stove":
			GameState.say("しおん", "お鍋は、流しにあるよ。")
			return
		GameState.force_hand("pot")
		if GameState.pot_water:
			GameState.say("しおん", "星くずの水が入った鍋。流しにも、コンロにも置けるよ。")
		else:
			GameState.say("しおん", "まだ何も入っていない。流しに置くと、水をためられるよ。")
		return
	if GameState.pot_place == "sink":
		GameState.force_hand("pot")
		if GameState.pot_water:
			GameState.say("しおん", "水の入った鍋を持った。コンロに戻そう。")
		else:
			GameState.say("しおん", "お鍋を持った。蛇口をひねると、水が貯まるよ。")
		return
	GameState.say("しおん", "流しだよ。お鍋を置くと、水をためられる。")


func _kitchen_try_fill() -> void:
	if GameState.fill_pot_in_sink(GameState.has_flag("kitchenFaucet")):
		GameState.say("流し", "白い星くずが、鍋にたまっていった。")


func _place_kitchen_water() -> void:
	if _water == null:
		return
	_water.position = Vector2(size.x * 0.099, size.y * 0.485)
	var on := GameState.scene == "kitchen" and GameState.has_flag("kitchenFaucet")
	_water.emitting = on
	_water.visible = on


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


func _gui_input(event: InputEvent) -> void:
	if GameState.fading:
		return
	var released := false
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and not mb.pressed:
			released = true
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if not touch.pressed:
			released = true
	if not released:
		return
	if _over_hotspot():
		return
	var now := Time.get_ticks_msec()
	if now - _last_miss_msec < 380:
		return
	_last_miss_msec = now
	Art.spark_at(_fx, get_global_mouse_position())
	if GameState.hand == "pot":
		GameState.say("しおん", "コンロか、流しをタップして置いてね。")
		return
	var lines: Array = MISS_LINES.get(GameState.scene, MISS_LINES["kitchen"])
	GameState.say("しおん", str(lines[_miss_i % lines.size()]))
	_miss_i += 1


func _over_hotspot() -> bool:
	var pos := get_global_mouse_position()
	for c in _spots.get_children():
		if c is Control and (c as Control).get_global_rect().has_point(pos):
			return true
	return false


func _process(_delta: float) -> void:
	if _held_fx == null:
		return
	var holding := GameState.scene == "kitchen" and GameState.hand == "pot"
	_held_fx.visible = holding
	if _held_water:
		_held_water.visible = holding and GameState.pot_water
	if not holding:
		return
	if _held_fx.texture == null:
		_held_fx.texture = load(Hotspots.POT_ART)
	if _held_water and _held_water.texture == null:
		_held_water.texture = load("res://assets/art/pot-liquid-water.png")
	var p := get_global_mouse_position()
	var r := get_global_rect()
	p.x = clampf(p.x, r.position.x + 8.0, r.position.x + maxf(24.0, r.size.x - 8.0))
	p.y = clampf(p.y, r.position.y + 8.0, r.position.y + maxf(24.0, r.size.y - 8.0))
	_held_fx.global_position = p + Vector2(10, -78)
	if _held_water:
		_held_water.global_position = p + Vector2(36, -70)
