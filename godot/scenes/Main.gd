extends Control

@onready var hud: PanelContainer = $Root/Hud
@onready var place_label: Label = $Root/Hud/HudCol/TopRow/Place
@onready var inventory: HFlowContainer = $Root/Hud/HudCol/Inventory
@onready var back_btn: Button = $Root/Hud/HudCol/TopRow/Back
@onready var cook_btn: Button = $Root/Hud/HudCol/TopRow/Cook
@onready var quit_btn: Button = $Root/Hud/HudCol/TopRow/Quit
@onready var host: Control = $Root/StageHost/Stage
@onready var stage_host: AspectRatioContainer = $Root/StageHost
@onready var root_box: VBoxContainer = $Root
@onready var overlay: Control = $Overlay
@onready var chrome_host: VBoxContainer = $Overlay/ChromeHost
@onready var dialogue: PanelContainer = $Root/Dialogue
@onready var speaker: Label = $Root/Dialogue/DialogueCol/Speaker
@onready var body: Label = $Root/Dialogue/DialogueCol/Body
@onready var fade: ColorRect = $Fade
@onready var hand_label: Label = $Root/Hud/HudCol/TopRow/Hand
@onready var moment: Control = $Moment

const FANFARE_ICONS := {
	"potato": "res://assets/art/potato.png",
	"onion": "res://assets/art/onion.png",
	"moonMilk": "res://assets/art/icon-milk.png",
	"starSalt": "res://assets/art/icon-salt.png",
}

var _moment_dim: ColorRect
var _moment_card: PanelContainer
var _moment_col: VBoxContainer
var _moment_kicker: Label
var _moment_icon: TextureRect
var _moment_title: Label
var _moment_hint: Label
var _moment_spark: CPUParticles2D
var _moment_token := 0
var _moment_mode := ""
var _moment_opened_msec := 0


func _ready() -> void:
	Art.boot()
	_apply_theme()
	_build_moment()
	GameState.scene_changed.connect(_on_scene)
	GameState.inventory_changed.connect(_refresh_hud)
	GameState.flags_changed.connect(_refresh_hud)
	GameState.dialogue_changed.connect(_refresh_dialogue)
	GameState.fading_changed.connect(_on_fade)
	GameState.hand_changed.connect(_refresh_hud)
	GameState.item_got.connect(_on_item_got)
	GameState.dish_ready.connect(_on_dish_ready)
	back_btn.pressed.connect(_on_back)
	cook_btn.pressed.connect(_on_cook)
	quit_btn.pressed.connect(func() -> void: GameState.reset())
	resized.connect(_adapt_layout)
	get_viewport().size_changed.connect(_adapt_layout)
	_show_scene(GameState.scene)
	_refresh_hud()
	_refresh_dialogue()
	_adapt_layout()


func _apply_theme() -> void:
	var theme := Theme.new()
	theme.default_font = Art.font
	theme.default_font_size = 15
	theme.set_color("font_color", "Label", Art.CREAM)
	theme.set_color("font_color", "Button", Art.CREAM)
	theme.set_color("font_hover_color", "Button", Art.GOLD)
	theme.set_stylebox("normal", "Button", Art.ghost_style())
	theme.set_stylebox("hover", "Button", Art.ghost_style())
	theme.set_stylebox("pressed", "Button", Art.ghost_style())
	theme.set_stylebox("panel", "PanelContainer", Art.panel_style())
	self.theme = theme
	cook_btn.add_theme_stylebox_override("normal", Art.primary_style())
	cook_btn.add_theme_stylebox_override("hover", Art.primary_style())
	cook_btn.add_theme_color_override("font_color", Art.NAVY)
	place_label.add_theme_color_override("font_color", Art.GOLD)
	place_label.add_theme_font_size_override("font_size", 16)
	speaker.add_theme_color_override("font_color", Art.GOLD)


func _on_scene(_scene: String) -> void:
	_show_scene(GameState.scene)
	_refresh_hud()
	_refresh_dialogue()


func _show_scene(scene_id: String) -> void:
	if scene_id != "cooking":
		GameState.clear_hand()
	for c in host.get_children():
		c.queue_free()
	var screen: Control
	match scene_id:
		"title":
			screen = TitleScreen.new()
		"ending":
			screen = EndingScreen.new()
		"cooking":
			screen = CookingScreen.new()
		_:
			screen = AdventureScreen.new()
	screen.layout_mode = 1
	screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen.anchor_left = 0
	screen.anchor_top = 0
	screen.anchor_right = 1
	screen.anchor_bottom = 1
	host.add_child(screen)
	if _moment_mode != "dish":
		_hide_moment()
	var show_hud := scene_id != "title" and scene_id != "ending"
	hud.visible = show_hud
	dialogue.visible = show_hud
	_adapt_layout()


func _refresh_hud() -> void:
	var scene_id := GameState.scene
	place_label.text = str(Hotspots.TITLES.get(scene_id, ""))
	hand_label.visible = scene_id == "cooking"
	hand_label.text = "手: %s" % Hotspots.HAND_NAMES.get(GameState.hand, GameState.hand)
	back_btn.visible = Hotspots.BACK.has(scene_id)
	cook_btn.visible = GameState.can_cook() and scene_id != "cooking" and scene_id != "title" and scene_id != "ending"
	for c in inventory.get_children():
		c.queue_free()
	if GameState.items.is_empty():
		var empty := Label.new()
		empty.text = "もちものなし"
		empty.modulate = Color(1, 1, 1, 0.55)
		inventory.add_child(empty)
	else:
		for id in GameState.items:
			inventory.add_child(_item_chip(id))


func _item_chip(id: String) -> Button:
	var meta: Dictionary = Hotspots.ITEM_META.get(id, {"name": id, "icon": ""})
	var b := Button.new()
	b.text = str(meta["name"])
	b.tooltip_text = str(meta["name"])
	b.custom_minimum_size = Vector2(0, 32)
	var held := GameState.hand
	if held.begins_with("chopped_"):
		held = held.substr(8)
	if GameState.scene == "cooking" and held == id:
		b.add_theme_stylebox_override("normal", Art.primary_style())
		b.add_theme_color_override("font_color", Art.NAVY)
	if GameState.scene == "cooking":
		b.pressed.connect(func() -> void: _pick_item(id))
	else:
		b.disabled = true
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return b


func _pick_item(id: String) -> void:
	if id == "memo":
		GameState.say("メモ", "月あかりポタージュ：星いも、月たまねぎ、月牛乳、仕上げに星しお。")
		return
	for c in host.get_children():
		if c.has_method("hold_from_inventory"):
			c.hold_from_inventory(id)
			return
	GameState.set_hand(id)
	GameState.say("しおん", "%sを手に持った。" % Hotspots.HAND_NAMES.get(id, id))


func _refresh_dialogue() -> void:
	speaker.text = str(GameState.dialogue.get("speaker", ""))
	body.text = str(GameState.dialogue.get("text", ""))


func _on_back() -> void:
	var next: String = Hotspots.BACK.get(GameState.scene, "")
	if next != "":
		GameState.go_to(next)


func _on_cook() -> void:
	GameState.go_to("cooking", "しおん", "そろったね。つくってみよう。")


func _on_fade(on: bool) -> void:
	var tw := create_tween()
	tw.tween_property(fade, "modulate:a", 1.0 if on else 0.0, 0.26)


func _chrome_visible() -> bool:
	return GameState.scene != "title" and GameState.scene != "ending"


func _adapt_layout() -> void:
	if not is_node_ready():
		return
	stage_host.stretch_mode = AspectRatioContainer.STRETCH_FIT
	stage_host.ratio = 16.0 / 9.0
	var show_chrome := _chrome_visible()
	if not show_chrome:
		_layout_fullbleed()
		return
	var aspect := size.x / maxf(size.y, 1.0)
	if aspect >= 1.55:
		_layout_wide()
	else:
		_layout_stack()


func _layout_fullbleed() -> void:
	_return_chrome_to_stack()
	root_box.add_theme_constant_override("separation", 0)
	root_box.offset_left = 0.0
	root_box.offset_top = 0.0
	root_box.offset_right = 0.0
	root_box.offset_bottom = 0.0
	stage_host.alignment_horizontal = 1
	stage_host.alignment_vertical = 1
	chrome_host.visible = false
	hud.visible = false
	dialogue.visible = false


func _layout_stack() -> void:
	_return_chrome_to_stack()
	root_box.add_theme_constant_override("separation", 10)
	root_box.offset_left = 12.0
	root_box.offset_top = 12.0
	root_box.offset_right = -12.0
	root_box.offset_bottom = -12.0
	dialogue.custom_minimum_size = Vector2(0, 88)
	hud.size_flags_vertical = Control.SIZE_FILL
	dialogue.size_flags_vertical = Control.SIZE_FILL
	stage_host.alignment_horizontal = 1
	stage_host.alignment_vertical = 0
	chrome_host.visible = false
	hud.visible = true
	dialogue.visible = true


func _layout_wide() -> void:
	var chrome_w := _chrome_width()
	root_box.add_theme_constant_override("separation", 0)
	root_box.offset_left = 6.0
	root_box.offset_top = 6.0
	root_box.offset_right = -(chrome_w + 8.0)
	root_box.offset_bottom = -6.0
	stage_host.alignment_horizontal = 1
	stage_host.alignment_vertical = 1
	if hud.get_parent() != chrome_host:
		hud.reparent(chrome_host, false)
		dialogue.reparent(chrome_host, false)
	hud.layout_mode = 2
	dialogue.layout_mode = 2
	hud.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dialogue.size_flags_vertical = Control.SIZE_FILL
	dialogue.custom_minimum_size = Vector2(0, 108)
	chrome_host.visible = true
	chrome_host.layout_mode = 1
	chrome_host.anchor_left = 1.0
	chrome_host.anchor_top = 0.0
	chrome_host.anchor_right = 1.0
	chrome_host.anchor_bottom = 1.0
	chrome_host.offset_left = -(chrome_w + 2.0)
	chrome_host.offset_top = 6.0
	chrome_host.offset_right = -6.0
	chrome_host.offset_bottom = -6.0
	hud.visible = true
	dialogue.visible = true


func _chrome_width() -> float:
	var fit_w := size.y * 16.0 / 9.0
	var leftover := maxf(0.0, size.x - fit_w)
	var w := leftover
	if leftover < 176.0:
		w = clampf(size.x * 0.26, 168.0, 240.0)
	else:
		w = clampf(leftover - 12.0, 176.0, 300.0)
	var min_stage := size.y * 16.0 / 9.0 * 0.72
	w = minf(w, maxf(160.0, size.x - min_stage - 12.0))
	return w


func _return_chrome_to_stack() -> void:
	if hud.get_parent() == root_box:
		return
	hud.reparent(root_box, false)
	dialogue.reparent(root_box, false)
	root_box.move_child(hud, 0)
	root_box.move_child(stage_host, 1)
	root_box.move_child(dialogue, 2)
	hud.layout_mode = 2
	dialogue.layout_mode = 2
	hud.size_flags_vertical = Control.SIZE_FILL
	dialogue.size_flags_vertical = Control.SIZE_FILL


func _build_moment() -> void:
	_moment_dim = ColorRect.new()
	_moment_dim.color = Color(0.027, 0.043, 0.11, 0.72)
	_moment_dim.layout_mode = 1
	_moment_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_moment_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_moment_dim.gui_input.connect(_on_moment_input)
	moment.add_child(_moment_dim)

	_moment_spark = CPUParticles2D.new()
	_moment_spark.emitting = false
	_moment_spark.amount = 28
	_moment_spark.lifetime = 1.1
	_moment_spark.explosiveness = 0.35
	_moment_spark.direction = Vector2(0, -1)
	_moment_spark.spread = 180
	_moment_spark.initial_velocity_min = 20
	_moment_spark.initial_velocity_max = 90
	_moment_spark.gravity = Vector2(0, 28)
	_moment_spark.color = Art.GOLD
	_moment_spark.z_index = 2
	moment.add_child(_moment_spark)

	_moment_card = PanelContainer.new()
	_moment_card.layout_mode = 1
	_moment_card.anchor_left = 0.5
	_moment_card.anchor_top = 0.5
	_moment_card.anchor_right = 0.5
	_moment_card.anchor_bottom = 0.5
	_moment_card.add_theme_stylebox_override("panel", Art.moment_style())
	_moment_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	moment.add_child(_moment_card)

	_moment_col = VBoxContainer.new()
	_moment_col.alignment = BoxContainer.ALIGNMENT_CENTER
	_moment_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_moment_col.add_theme_constant_override("separation", 10)
	_moment_card.add_child(_moment_col)

	_moment_kicker = Label.new()
	_moment_kicker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_moment_kicker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_moment_kicker.add_theme_color_override("font_color", Art.GOLD)
	_moment_kicker.add_theme_font_size_override("font_size", 15)
	_moment_col.add_child(_moment_kicker)

	_moment_icon = TextureRect.new()
	_moment_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_moment_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_moment_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_moment_icon.material = Art.chroma
	_moment_icon.custom_minimum_size = Vector2(220, 220)
	_moment_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_moment_col.add_child(_moment_icon)

	_moment_title = Label.new()
	_moment_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_moment_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_moment_title.add_theme_color_override("font_color", Art.CREAM)
	_moment_title.add_theme_font_size_override("font_size", 22)
	_moment_col.add_child(_moment_title)

	_moment_hint = Label.new()
	_moment_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_moment_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_moment_hint.add_theme_color_override("font_color", Color(0.957, 0.937, 0.894, 0.75))
	_moment_hint.add_theme_font_size_override("font_size", 13)
	_moment_col.add_child(_moment_hint)


func _on_item_got(id: String) -> void:
	var path := str(FANFARE_ICONS.get(id, ""))
	if path == "":
		return
	var name := str(Hotspots.ITEM_META.get(id, {}).get("name", id))
	_open_moment("get", path, "手に入れた！", name, "タップしてつづける", Vector2(280, 240))


func _on_dish_ready() -> void:
	_open_moment(
		"dish",
		"res://assets/art/potage-hero.png",
		"できたよ",
		"月あかりポタージュ",
		"タップしてつづける",
		Vector2(420, 380)
	)


func _open_moment(mode: String, icon_path: String, kicker: String, title: String, hint: String, icon_size: Vector2) -> void:
	_moment_token += 1
	var token := _moment_token
	_moment_mode = mode
	_moment_opened_msec = Time.get_ticks_msec()
	_moment_kicker.text = kicker
	_moment_title.text = title
	_moment_hint.text = hint
	_moment_icon.texture = load(icon_path)
	_moment_icon.custom_minimum_size = icon_size
	var card_w := 340.0 if mode == "get" else minf(size.x * 0.82, 560.0)
	var card_h := 420.0 if mode == "get" else minf(size.y * 0.86, 640.0)
	_moment_card.offset_left = -card_w * 0.5
	_moment_card.offset_right = card_w * 0.5
	_moment_card.offset_top = -card_h * 0.5
	_moment_card.offset_bottom = card_h * 0.5
	_moment_spark.position = size * 0.5
	_moment_spark.emitting = false
	_moment_spark.restart()
	_moment_spark.emitting = true
	moment.visible = true
	moment.mouse_filter = Control.MOUSE_FILTER_STOP
	_moment_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_moment_card.pivot_offset = Vector2(card_w, card_h) * 0.5
	_moment_card.scale = Vector2(0.72, 0.72)
	var tw := _moment_card.create_tween()
	tw.set_trans(Tween.TRANS_BACK)
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(_moment_card, "scale", Vector2(1.06, 1.06), 0.28)
	tw.tween_property(_moment_card, "scale", Vector2.ONE, 0.16)
	if mode == "get":
		await get_tree().create_timer(2.0).timeout
		if token == _moment_token and _moment_mode == "get" and moment.visible:
			_hide_moment()


func _on_moment_input(event: InputEvent) -> void:
	if not moment.visible:
		return
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		if not (event is InputEventScreenTouch and event.pressed):
			return
	if Time.get_ticks_msec() - _moment_opened_msec < 350:
		return
	_dismiss_moment()


func _dismiss_moment() -> void:
	if not moment.visible:
		return
	if _moment_mode == "dish":
		_hide_moment()
		GameState.go_to(
			"ending",
			"しおん",
			"あったかい……星が、お腹のなかで溶けていく。ありがとう。"
		)
		return
	_hide_moment()


func _hide_moment() -> void:
	_moment_token += 1
	_moment_mode = ""
	if _moment_spark:
		_moment_spark.emitting = false
	moment.visible = false
	moment.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _moment_dim:
		_moment_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
