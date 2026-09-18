class_name CookingScreen
extends Control

var water_on := false
var pot_water := false
var pot_potato := false
var pot_onion := false
var pot_milk := false
var pot_fire := false
var pot_salt := false
var board := ""
var used := {}
var _fx: Node2D
var _water: CPUParticles2D
var _board_item: TextureRect
var _bowl: TextureRect
var _overlays: Control
var _done := false

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	layout_mode = 1
	Art.backdrop(self, "res://assets/art/cooking.png")
	_overlays = Control.new()
	_overlays.layout_mode = 1
	_overlays.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlays.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlays)

	_fx = Node2D.new()
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

	Art.hotspot(self, "蛇口", 0, 36, 18, 36, _on_faucet)
	Art.hotspot(self, "お鍋", 18, 28, 18, 26, _on_pot)
	Art.hotspot(self, "火", 20, 52, 14, 16, _on_fire)
	Art.hotspot(self, "まな板", 40, 58, 36, 28, _on_board)
	Art.hotspot(self, "包丁", 74, 58, 16, 20, _on_knife)

	var knife := Art.sprite(_overlays, "res://assets/art/icon-knife.png", 76, 58, 12, 18, false, false)
	knife.name = "KnifeIcon"

	GameState.hand_changed.connect(_refresh_visuals)
	GameState.say("しおん", "材料を持って、気になるところへ。蛇口も包丁も、触ってみて。")
	_refresh_visuals()


func _place_fx() -> void:
	_fx.position = Vector2(size.x * 0.09, size.y * 0.48)


func _hint(text: String) -> void:
	GameState.say("しおん", text)


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
		GameState.clear_hand()
		_hint("包丁をテーブルに戻した。")
	elif GameState.hand == "":
		GameState.set_hand("knife")
		_hint("包丁を持った。まな板の上のものを切れるよ。")
	else:
		_hint("今は%sを持っているよ。先に置いてから包丁を持ってね。" % Hotspots.HAND_NAMES.get(GameState.hand, GameState.hand))
	_refresh_visuals()


func _on_board() -> void:
	var hand := GameState.hand
	if hand == "potato":
		if board != "":
			_hint("まな板の上は、もういっぱい。")
			return
		if used.get("potato", false):
			_hint("星いもは、もうまな板にのせたよ。")
			return
		board = "potato"
		used["potato"] = true
		GameState.clear_hand()
		_hint("いもがまな板にのった。まだ星のかたち。")
	elif hand == "onion":
		if board != "":
			_hint("まな板の上は、もういっぱい。")
			return
		if used.get("onion", false):
			_hint("月たまねぎは、もう切る番を待っているよ。")
			return
		board = "onion"
		used["onion"] = true
		GameState.clear_hand()
		_hint("三日月の層が光っている。")
	elif hand == "knife":
		if board == "potato":
			board = "chopped_potato"
			_chop()
			_hint("こんにゃくみたいに、やわらかく切れた。")
		elif board == "onion":
			board = "chopped_onion"
			_chop()
			_hint("塩の香りがふわっとした。涙は出ないみたい。")
		elif board == "chopped_potato" or board == "chopped_onion":
			_hint("もう細かいよ。鍋へ入れよう。")
		else:
			_hint("切るものがまだないよ。星いもを持って、まな板に置いてみて。")
	elif hand == "":
		if board == "chopped_potato" or board == "chopped_onion":
			GameState.set_hand(board)
			board = ""
			_hint("切った具を手に持った。鍋へどうぞ。")
		elif board == "potato" or board == "onion":
			_hint("包丁を持って、これを切ってみて。")
		else:
			_hint("まな板だよ。星いもを持って置いてみて。")
	elif hand == "moonMilk" or hand == "starSalt":
		_hint("それは鍋へ。まな板じゃなくていいよ。")
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
		pot_potato = true
		GameState.clear_hand()
		_hint("鍋の底で、星くずがちょっとはねた。")
	elif hand == "chopped_onion":
		if not pot_water:
			_hint("先に星くずの水を鍋へ入れてね。")
			return
		pot_onion = true
		GameState.clear_hand()
		_hint("三日月の香りが、湯気に混ざった。")
	elif hand == "potato" or hand == "onion":
		_hint("先にまな板で切ろう。")
	elif hand == "moonMilk":
		if not pot_potato or not pot_onion:
			_hint("まだ野菜がそろってないよ。切ってから牛乳を注ごう。")
			return
		pot_milk = true
		GameState.clear_hand()
		_hint("白い湯気が、夜空みたいに立ちのぼる。")
	elif hand == "starSalt":
		if not pot_fire:
			_hint("まだ早いよ。火をつけてから、仕上げの星しお。")
			return
		pot_salt = true
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
	if not pot_potato or not pot_onion or not pot_milk:
		_hint("具と牛乳を入れてから、火をつけよう。焦らなくていい。")
		return
	pot_fire = true
	_hint("小さな青い炎。島の火は、いつも少し冷たい。")
	_refresh_visuals()
	_check_done()


func _status_hint() -> String:
	if not pot_water:
		return "蛇口をひねって、星くずの水を鍋へ。"
	if not pot_potato:
		return "星いもを持って、まな板へ置いて切ってね。"
	if not pot_onion:
		return "月たまねぎも、同じように切って鍋へ。"
	if not pot_milk:
		return "月牛乳を持って、鍋に注いで。"
	if not pot_fire:
		return "火をつけて。"
	if not pot_salt:
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


func _refresh_visuals() -> void:
	if _board_item:
		_board_item.queue_free()
		_board_item = null
	if _bowl:
		_bowl.queue_free()
		_bowl = null
	var knife_icon := _overlays.get_node_or_null("KnifeIcon") as TextureRect
	if knife_icon:
		knife_icon.visible = GameState.hand != "knife"
	if board != "":
		var path := "res://assets/art/potato.png"
		if board == "onion" or board == "chopped_onion":
			path = "res://assets/art/onion.png"
		_board_item = Art.sprite(_overlays, path, 52, 62, 14, 16, false, board.begins_with("chopped"))
		if board.begins_with("chopped"):
			_board_item.modulate = Color(0.92, 0.95, 1.0, 1.0)
	if pot_fire and not _done:
		_bowl = Art.sprite(_overlays, "res://assets/art/bowl-cook-sheet.png", 48, 38, 22, 28, true, true)
	if _done:
		_bowl = Art.sprite(_overlays, "res://assets/art/bowl-finished.png", 48, 38, 24, 30)


func _check_done() -> void:
	if _done:
		return
	if pot_water and pot_potato and pot_onion and pot_milk and pot_fire and pot_salt:
		_done = true
		_refresh_visuals()
		GameState.say("しおん", "月あかりポタージュ、できたよ。")
		await get_tree().create_timer(1.2).timeout
		await GameState.go_to(
			"ending",
			"しおん",
			"あったかい……星が、お腹のなかで溶けていく。ありがとう。"
		)
