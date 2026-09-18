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
	"moonMilk": "res://assets/art/cook-milk.png",
	"starSalt": "res://assets/art/cook-salt.png",
	"knife": "res://assets/art/cook-knife.png",
}

const POT_ICON := {
	"potato": [22.5, 31.5, 6.5, 8.5],
	"onion": [27.5, 33.0, 6.0, 8.0],
	"moonMilk": [25.0, 28.5, 5.0, 9.0],
	"starSalt": [29.5, 30.0, 4.5, 6.5],
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
	resized.connect(_place_fx)
	_place_fx()

	Art.hotspot(self, "蛇口", 0, 32, 18, 38, _on_faucet)
	Art.hotspot(self, "お鍋", 18, 26, 18, 28, _on_pot)
	Art.hotspot(self, "火", 20, 52, 14, 16, _on_fire)
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
	_fx.position = Vector2(size.x * 0.09, size.y * 0.48)


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
				_refresh_visuals()
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
	var tw := _board_item.create_tween()
	tw.tween_property(_board_item, "scale", Vector2(1.05, 0.72), 0.08)
	tw.tween_property(_board_item, "scale", Vector2(1, 1), 0.1)
	tw.tween_property(_board_item, "scale", Vector2(1.05, 0.72), 0.08)
	tw.tween_property(_board_item, "scale", Vector2(1, 1), 0.1)


func _process(_delta: float) -> void:
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


func _update_held_tex() -> void:
	if _held_fx == null:
		return
	var hand := GameState.hand
	var key := _family(hand)
	if hand == "knife":
		key = "knife"
	if hand == "" or not ART.has(key):
		_held_fx.texture = null
		return
	_held_fx.texture = load(ART[key])
	if hand.begins_with("chopped_"):
		_held_fx.modulate = Color(0.92, 0.95, 1.0)
	else:
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
		Art.sprite(_overlays, "res://assets/art/water-stream.png", 6.4, 40.5, 5.2, 22.0, false, false)

	if pot_fire and not _done:
		Art.sprite(_overlays, "res://assets/art/icon-fire.png", 23.5, 47.0, 8.0, 12.5, false, true)
		Art.sprite(_overlays, "res://assets/art/bowl-cook-sheet.png", 21.5, 24.0, 14.0, 20.0, true, true)

	if _done:
		Art.sprite(_overlays, "res://assets/art/bowl-finished.png", 21.0, 22.0, 16.0, 22.0)

	for id in SHELF:
		if loc.get(id, "") != "shelf":
			continue
		var pos: Array = SHELF[id]
		var spr := Art.sprite(_overlays, ART[id], float(pos[0]), float(pos[1]), float(pos[2]), float(pos[3]), false, true)
		if chopped.get(id, false):
			spr.modulate = Color(0.92, 0.95, 1.0)

	var occ := _board_occupant()
	if occ != "":
		_board_item = Art.sprite(_overlays, ART[occ], 46.0, 60.0, 13.0, 17.0, false, chopped[occ])
		if chopped[occ]:
			_board_item.modulate = Color(0.92, 0.95, 1.0)

	if not _done:
		for id in POT_ICON:
			if loc.get(id, "") != "pot":
				continue
			var p: Array = POT_ICON[id]
			var s := Art.sprite(_overlays, ART[id], float(p[0]), float(p[1]), float(p[2]), float(p[3]), false, false)
			s.modulate = Color(1, 1, 1, 0.92)


func _check_done() -> void:
	if _done:
		return
	if pot_water and pot_fire and loc.get("potato", "") == "pot" and loc.get("onion", "") == "pot" and loc.get("moonMilk", "") == "pot" and loc.get("starSalt", "") == "pot":
		_done = true
		_refresh_visuals()
		GameState.say("しおん", "月あかりポタージュ、できたよ。")
		await get_tree().create_timer(1.2).timeout
		await GameState.go_to(
			"ending",
			"しおん",
			"あったかい……星が、お腹のなかで溶けていく。ありがとう。"
		)
