class_name CookingScreen
extends Control

const SHELF := {
	"potato": [0.3, 5.0, 8.2, 17.0],
	"onion": [8.0, 5.0, 8.0, 17.0],
	"moonMilk": [15.6, 3.2, 6.2, 18.8],
	"starSalt": [21.2, 7.0, 5.8, 13.0],
}

const ART := {
	"potato": "res://assets/art/cook-potato.png",
	"onion": "res://assets/art/cook-onion.png",
	"chopped_potato": "res://assets/art/cook-potato-chopped.png",
	"chopped_onion": "res://assets/art/cook-onion-chopped.png",
	"moonMilk": "res://assets/art/cook-milk.png",
	"starSalt": "res://assets/art/cook-salt.png",
	"knife": "res://assets/art/cook-knife.png",
}

var loc := {
	"potato": "shelf",
	"onion": "shelf",
	"moonMilk": "shelf",
	"starSalt": "shelf",
	"knife": "table",
}
var chopped := {
	"potato": false,
	"onion": false,
}
var water_on := false
var pot_water := false
var pot_fire := false
var _done := false
var _fx: Node2D
var _water: CPUParticles2D
var _pot_fx: Node2D
var _salt_burst: CPUParticles2D
var _salt_twinkle: CPUParticles2D
var _salt_sparking := false
var _orbit_stars: Array[Sprite2D] = []
var _orbit_t := 0.0
var _overlays: Control
var _held_fx: TextureRect
var _board_item: TextureRect
var _shelf_btns := {}

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	layout_mode = 1
	mouse_filter = Control.MOUSE_FILTER_STOP
	GameState.clear_hand()
	Art.backdrop(self, "res://assets/art/cooking.png")
	_overlays = Control.new()
	_overlays.layout_mode = 1
	_overlays.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlays.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlays)

	_fx = Node2D.new()
	_fx.z_index = 4
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

	_pot_fx = Node2D.new()
	_pot_fx.z_index = 12
	add_child(_pot_fx)
	_salt_burst = _make_salt_particles(true)
	_salt_twinkle = _make_salt_particles(false)
	_pot_fx.add_child(_salt_burst)
	_pot_fx.add_child(_salt_twinkle)

	resized.connect(_place_fx)
	_place_fx()

	Art.hotspot(self, "蛇口", 0, 32, 18, 38, _on_faucet)
	Art.hotspot(self, "お鍋", 18, 26, 18, 28, _on_pot)
	Art.hotspot(self, "火", 18, 44, 20, 26, _on_fire)
	Art.hotspot(self, "まな板", 38, 56, 28, 30, _on_board)
	Art.hotspot(self, "包丁", 64, 56, 18, 22, _on_knife)
	Art.hotspot(self, "棚", 0, 3, 26, 26, _on_shelf)

	for id in SHELF:
		var pos: Array = SHELF[id]
		var captured := str(id)
		_shelf_btns[id] = Art.hotspot(
			self,
			str(Hotspots.ITEM_META[id]["name"]),
			float(pos[0]),
			float(pos[1]),
			float(pos[2]),
			float(pos[3]),
			func() -> void: hold_from_inventory(captured)
		)

	_held_fx = TextureRect.new()
	_held_fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_held_fx.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_held_fx.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_held_fx.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_held_fx.material = Art.chroma
	_held_fx.size = Vector2(92, 92)
	_held_fx.z_index = 40
	_held_fx.visible = false
	add_child(_held_fx)

	GameState.hand_changed.connect(_refresh_visuals)
	GameState.say("しおん", "食材は左の棚。持ったらイラストがついてくるよ。置きたい場所をタップしてね。")
	_refresh_visuals()


func _place_fx() -> void:
	_fx.position = Vector2(size.x * 0.117, size.y * 0.48)
	if _pot_fx:
		_pot_fx.position = Vector2(size.x * 0.312, size.y * 0.405)
		var rad := minf(size.x, size.y) * 0.09
		if _salt_twinkle:
			_salt_twinkle.emission_sphere_radius = rad
		if _salt_burst:
			_salt_burst.emission_sphere_radius = rad * 0.45


func _hint(text: String) -> void:
	GameState.say("しおん", text)


func _family(hand: String) -> String:
	if hand.begins_with("chopped_"):
		return hand.substr(8)
	return hand


func _hand_id(id: String) -> String:
	if chopped.get(id, false) and (id == "potato" or id == "onion"):
		return "chopped_" + id
	return id


func _board_occupant() -> String:
	for id in ["potato", "onion"]:
		if loc.get(id, "") == "board":
			return id
	return ""


func _park_held(dest := "shelf") -> void:
	var hand := GameState.hand
	if hand == "":
		return
	if hand == "knife":
		loc["knife"] = "table"
		GameState.clear_hand()
		return
	var fam := _family(hand)
	if dest == "auto":
		if (fam == "potato" or fam == "onion") and _board_occupant() in ["", fam]:
			dest = "board"
		else:
			dest = "shelf"
	if dest == "board":
		var occ := _board_occupant()
		if occ != "" and occ != fam:
			dest = "shelf"
		else:
			loc[fam] = "board"
			GameState.clear_hand()
			return
	if dest == "pot":
		loc[fam] = "pot"
		GameState.clear_hand()
		return
	loc[fam] = "shelf"
	GameState.clear_hand()


func _cook_art(id: String) -> String:
	if chopped.get(id, false):
		var chopped_id := "chopped_" + id
		if ART.has(chopped_id):
			return ART[chopped_id]
	return str(ART.get(id, ""))


func _pot_has_food() -> bool:
	for id in ["potato", "onion", "moonMilk", "starSalt"]:
		if loc.get(id, "") == "pot":
			return true
	return false


func hold_from_inventory(id: String) -> void:
	if _done:
		return
	if id == "memo":
		GameState.say("メモ", "月あかりポタージュ：星いも、月たまねぎ、月牛乳、仕上げに星しお。")
		return
	if not loc.has(id):
		return
	if loc[id] == "pot":
		_hint("%sは、もう鍋のなかだよ。" % Hotspots.HAND_NAMES.get(id, id))
		return
	if _family(GameState.hand) == id:
		if id == "knife":
			_park_held("table")
			_hint("包丁をテーブルに戻した。")
		else:
			_park_held("shelf")
			_hint("棚に戻したよ。")
		_refresh_visuals()
		return
	if GameState.hand != "":
		_park_held("auto")
	if loc[id] == "board":
		loc[id] = "held"
		GameState.force_hand(_hand_id(id))
		_hint("%sを手に持った。鍋か棚へどうぞ。" % Hotspots.HAND_NAMES.get(_hand_id(id), id))
		_refresh_visuals()
		return
	loc[id] = "held"
	GameState.force_hand(_hand_id(id))
	_hint("%sを手に持った。置きたいところをタップしてね。" % Hotspots.HAND_NAMES.get(_hand_id(id), id))
	_refresh_visuals()


func _on_shelf() -> void:
	if _done:
		return
	var hand := GameState.hand
	if hand == "":
		_hint("食材が並んでいる棚。とりたいものをタップしてね。")
		return
	if hand == "knife":
		_park_held("table")
		_hint("包丁はまな板のところへ戻したよ。")
		_refresh_visuals()
		return
	_park_held("shelf")
	_hint("棚に戻したよ。")
	_refresh_visuals()


func _on_faucet() -> void:
	if _done:
		return
	if GameState.hand != "":
		_hint("蛇口は素手でひねってね。持っているものは、いったん置こう。")
		return
	water_on = not water_on
	_water.emitting = water_on
	if water_on:
		_hint("星くずの水が、さらさらと落ちてきた。つめたい。")
	else:
		_hint("水をとめた。鍋に入れた分は、残っているよ。")
	_refresh_visuals()


func _on_knife() -> void:
	if _done:
		return
	if GameState.hand == "knife":
		_park_held("table")
		_hint("包丁をテーブルに戻した。")
	elif GameState.hand == "":
		loc["knife"] = "held"
		GameState.force_hand("knife")
		_hint("包丁を持った。まな板の上のものを切れるよ。")
	else:
		var name: String = Hotspots.HAND_NAMES.get(GameState.hand, GameState.hand)
		_hint("今は%sを持っているよ。先に置いてから包丁を持ってね。" % name)
	_refresh_visuals()


func _on_board() -> void:
	if _done:
		return
	var hand := GameState.hand
	if hand == "knife":
		var occ := _board_occupant()
		if occ == "potato" or occ == "onion":
			if chopped[occ]:
				_hint("もう細かいよ。鍋へ入れよう。")
			else:
				chopped[occ] = true
				if occ == "potato":
					_hint("こんにゃくみたいに、やわらかく切れた。")
				else:
					_hint("塩の香りがふわっとした。涙は出ないみたい。")
				_chop()
				return
		else:
			_hint("切るものがまだないよ。棚の星いもを持って、まな板に置いてみて。")
	elif hand == "potato" or hand == "chopped_potato" or hand == "onion" or hand == "chopped_onion":
		var fam := _family(hand)
		var occ := _board_occupant()
		if occ != "" and occ != fam:
			_hint("まな板の上は、もういっぱい。")
			return
		loc[fam] = "board"
		GameState.clear_hand()
		if fam == "potato":
			if chopped[fam]:
				_hint("切った星いもを、まな板にのせたよ。")
			else:
				_hint("いもがまな板にのった。まだ星のかたち。")
		else:
			if chopped[fam]:
				_hint("切った月たまねぎを、まな板にのせたよ。")
			else:
				_hint("三日月の層が光っている。")
	elif hand == "moonMilk" or hand == "starSalt":
		_hint("それは鍋へ。まな板じゃなくていいよ。")
	elif hand == "":
		var occ := _board_occupant()
		if occ != "":
			loc[occ] = "held"
			GameState.force_hand(_hand_id(occ))
			if chopped[occ]:
				_hint("切った具を手に持った。鍋へどうぞ。")
			else:
				_hint("まだ切ってないよ。包丁を持って、これを切ってみて。")
		else:
			_hint("まな板だよ。棚の星いもを持って置いてみて。")
	else:
		_hint("別の順番でも大丈夫、焦らなくていい。")
	_refresh_visuals()
	_check_done()


func _on_pot() -> void:
	if _done:
		return
	var hand := GameState.hand
	if water_on and not pot_water and hand == "":
		pot_water = true
		_hint("白い星くずが鍋に落ちた。月の湯気の準備。")
		_refresh_visuals()
		_check_done()
		return
	if hand == "chopped_potato":
		if not pot_water:
			_hint("先に蛇口から、星くずの水を鍋へ。")
			return
		loc["potato"] = "pot"
		GameState.clear_hand()
		_hint("鍋の底で、星くずがちょっとはねた。")
	elif hand == "chopped_onion":
		if not pot_water:
			_hint("先に星くずの水を鍋へ入れてね。")
			return
		loc["onion"] = "pot"
		GameState.clear_hand()
		_hint("三日月の香りが、湯気に混ざった。")
	elif hand == "potato" or hand == "onion":
		_hint("先にまな板で切ろう。")
	elif hand == "moonMilk":
		if loc.get("potato", "") != "pot" or loc.get("onion", "") != "pot":
			_hint("まだ野菜がそろってないよ。切ってから牛乳を注ごう。")
			return
		loc["moonMilk"] = "pot"
		GameState.clear_hand()
		_hint("白い湯気が、夜空みたいに立ちのぼる。")
	elif hand == "starSalt":
		if not pot_fire:
			_hint("まだ早いよ。火をつけてから、仕上げの星しお。")
			return
		loc["starSalt"] = "pot"
		GameState.clear_hand()
		_hint("粒がスープの表面で、短い星になった。")
		_begin_salt_sparkle()
	elif hand == "knife":
		_hint("包丁はまな板で使ってね。")
	elif hand == "":
		if not pot_water:
			if water_on:
				pot_water = true
				_hint("白い星くずが鍋に落ちた。月の湯気の準備。")
			else:
				_hint("蛇口をひねって、星くずの水を出してね。")
		else:
			_hint(_status_hint())
	_refresh_visuals()
	_check_done()


func _on_fire() -> void:
	if _done:
		return
	if GameState.hand != "":
		_hint("火は素手でつけて。持っているものは、いったん置いてね。")
		return
	if not pot_water:
		_hint("空焚きはしないよ。先に水を鍋へ。")
		return
	if loc.get("potato", "") != "pot" or loc.get("onion", "") != "pot" or loc.get("moonMilk", "") != "pot":
		_hint("具と牛乳を入れてから、火をつけよう。焦らなくていい。")
		return
	pot_fire = true
	_hint("小さな青い炎。島の火は、いつも少し冷たい。")
	_refresh_visuals()
	_check_done()


func _status_hint() -> String:
	if not pot_water:
		return "蛇口をひねって、星くずの水を鍋へ。"
	if loc.get("potato", "") != "pot":
		if chopped.get("potato", false):
			return "切った星いもを持って、鍋へ入れてね。"
		return "星いもを棚から持って、まな板へ置いて切ってね。"
	if loc.get("onion", "") != "pot":
		return "月たまねぎも、同じように切って鍋へ。"
	if loc.get("moonMilk", "") != "pot":
		return "月牛乳を持って、鍋に注いで。"
	if not pot_fire:
		return "火をつけて。"
	if loc.get("starSalt", "") != "pot":
		return "仕上げに星しおをひとふり。"
	return "いい匂い。もう少しでできそう。"


func _chop() -> void:
	if _board_item == null:
		return
	var item := _board_item
	var tw := item.create_tween()
	tw.tween_property(item, "scale", Vector2(1.05, 0.72), 0.08)
	tw.tween_property(item, "scale", Vector2(1, 1), 0.1)
	tw.tween_property(item, "scale", Vector2(1.05, 0.72), 0.08)
	tw.tween_property(item, "scale", Vector2(1, 1), 0.1)
	await tw.finished
	if not is_inside_tree():
		return
	_refresh_visuals()


func _process(_delta: float) -> void:
	_tick_salt_orbit(_delta)
	if _held_fx == null:
		return
	if GameState.hand == "":
		_held_fx.visible = false
		return
	_held_fx.visible = true
	var p := get_global_mouse_position()
	var r := get_global_rect()
	p.x = clampf(p.x, r.position.x + 8.0, r.position.x + maxf(24.0, r.size.x - 8.0))
	p.y = clampf(p.y, r.position.y + 8.0, r.position.y + maxf(24.0, r.size.y - 8.0))
	_held_fx.global_position = p + Vector2(14, -86)


func _gui_input(event: InputEvent) -> void:
	if _done:
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT and GameState.hand != "":
			_hint("まな板、お鍋、棚のどれかをタップして置いてね。")


func _make_salt_particles(burst: bool) -> CPUParticles2D:
	Art.boot()
	var p := CPUParticles2D.new()
	p.emitting = false
	p.texture = load("res://assets/art/sparkle.png")
	p.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	p.amount = 48 if burst else 28
	p.lifetime = 0.85 if burst else 1.35
	p.one_shot = burst
	p.explosiveness = 0.88 if burst else 0.08
	p.randomness = 0.4
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE_SURFACE
	p.emission_sphere_radius = 48.0
	p.direction = Vector2(0, -1)
	p.spread = 180
	p.gravity = Vector2(0.0, -18.0 if burst else -8.0)
	p.initial_velocity_min = 22.0 if burst else 6.0
	p.initial_velocity_max = 86.0 if burst else 26.0
	p.angular_velocity_min = -90.0
	p.angular_velocity_max = 90.0
	p.scale_amount_min = 0.28 if burst else 0.18
	p.scale_amount_max = 0.72 if burst else 0.48
	var curve := Curve.new()
	curve.add_point(Vector2(0.0, 0.2))
	curve.add_point(Vector2(0.28, 1.0))
	curve.add_point(Vector2(1.0, 0.0))
	p.scale_amount_curve = curve
	p.color = Art.GOLD if burst else Art.SALT
	var grad := Gradient.new()
	if burst:
		grad.offsets = PackedFloat32Array([0.0, 0.35, 1.0])
		grad.colors = PackedColorArray([Color(1, 1, 1, 1), Art.GOLD, Color(Art.GOLD.r, Art.GOLD.g, Art.GOLD.b, 0)])
	else:
		grad.offsets = PackedFloat32Array([0.0, 0.45, 1.0])
		grad.colors = PackedColorArray([Color(1, 1, 1, 1), Art.SALT, Color(Art.GOLD.r, Art.GOLD.g, Art.GOLD.b, 0)])
	p.color_ramp = grad
	p.local_coords = true
	return p


func _begin_salt_sparkle() -> void:
	if _salt_sparking:
		return
	_salt_sparking = true
	_place_fx()
	_spawn_orbit_stars()
	if _salt_burst:
		_salt_burst.restart()
		_salt_burst.emitting = true
	if _salt_twinkle:
		_salt_twinkle.emitting = true


func _spawn_orbit_stars() -> void:
	for old in _orbit_stars:
		if is_instance_valid(old):
			old.queue_free()
	_orbit_stars.clear()
	var tex: Texture2D = load("res://assets/art/sparkle.png")
	for i in 8:
		var s := Sprite2D.new()
		s.texture = tex
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		s.centered = true
		_pot_fx.add_child(s)
		_orbit_stars.append(s)
	_orbit_t = 0.0
	_tick_salt_orbit(0.0)


func _tick_salt_orbit(delta: float) -> void:
	if not _salt_sparking or _orbit_stars.is_empty():
		return
	_orbit_t += delta
	var rx := minf(size.x, size.y) * 0.088
	var ry := rx * 0.52
	var n := _orbit_stars.size()
	for i in n:
		var s: Sprite2D = _orbit_stars[i]
		if not is_instance_valid(s):
			continue
		var a := _orbit_t * 1.45 + TAU * float(i) / float(n)
		s.position = Vector2(cos(a) * rx, sin(a) * ry - 6.0)
		var twinkle: float = 0.4 + 0.6 * absf(sin(_orbit_t * 7.2 + float(i) * 1.6))
		s.modulate = Color(1, 1, 1, twinkle)
		s.scale = Vector2.ONE * (0.42 + 0.5 * twinkle)


func _add_pot_liquid(path: String) -> void:
	Art.boot()
	var r := TextureRect.new()
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	r.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	r.material = Art.chroma
	r.texture = load(path)
	r.layout_mode = 1
	r.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlays.add_child(r)


func _update_held_tex() -> void:
	if _held_fx == null:
		return
	var hand := GameState.hand
	var key := _family(hand)
	if hand == "knife":
		key = "knife"
	if hand.begins_with("chopped_"):
		key = hand
	if hand == "" or not ART.has(key):
		_held_fx.texture = null
		return
	_held_fx.texture = load(ART[key])
	_held_fx.modulate = Color.WHITE


func _refresh_visuals() -> void:
	for c in _overlays.get_children():
		c.queue_free()
	_board_item = null
	_update_held_tex()

	for id in _shelf_btns:
		var btn: Button = _shelf_btns[id]
		var on_shelf: bool = loc.get(id, "") == "shelf"
		btn.visible = on_shelf
		btn.disabled = not on_shelf
		btn.mouse_filter = Control.MOUSE_FILTER_STOP if on_shelf else Control.MOUSE_FILTER_IGNORE

	if water_on:
		Art.sprite(_overlays, "res://assets/art/water-stream.png", 8.7, 40.5, 5.2, 22.0, false, false)

	if _done:
		_add_pot_liquid("res://assets/art/pot-potage.png")
	elif _pot_has_food():
		_add_pot_liquid("res://assets/art/pot-soup.png")
	elif pot_water:
		_add_pot_liquid("res://assets/art/pot-water.png")

	# Ingredient parts stack independently of add order.
	if loc.get("moonMilk", "") == "pot":
		_add_pot_liquid("res://assets/art/pot-milk-swirl.png")
	if loc.get("onion", "") == "pot":
		_add_pot_liquid("res://assets/art/pot-onion-bits.png")

	if pot_fire:
		for flame_x in [23.5, 27.2, 30.9]:
			Art.sprite(_overlays, "res://assets/art/icon-fire.png", flame_x, 47.0, 8.0, 12.5, false, true)

	for id in SHELF:
		if loc.get(id, "") != "shelf":
			continue
		var pos: Array = SHELF[id]
		Art.sprite(_overlays, _cook_art(id), float(pos[0]), float(pos[1]), float(pos[2]), float(pos[3]), false, true)

	var occ := _board_occupant()
	if occ != "":
		_board_item = Art.sprite(_overlays, _cook_art(occ), 46.0, 60.0, 13.0, 17.0, false, chopped[occ])

	if loc.get("knife", "") == "table":
		Art.sprite(_overlays, ART["knife"], 64.0, 57.5, 17.5, 19.0, false, false)


func _check_done() -> void:
	if _done:
		return
	if pot_water and pot_fire and loc.get("potato", "") == "pot" and loc.get("onion", "") == "pot" and loc.get("moonMilk", "") == "pot" and loc.get("starSalt", "") == "pot":
		_done = true
		_refresh_visuals()
		GameState.say("しおん", "月あかりポタージュ、できたよ。")
		await get_tree().create_timer(0.8).timeout
		if not is_inside_tree():
			return
		GameState.present_dish()
