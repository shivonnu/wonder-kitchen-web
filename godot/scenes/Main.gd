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

func _ready() -> void:
	Art.boot()
	_apply_theme()
	GameState.scene_changed.connect(_on_scene)
	GameState.inventory_changed.connect(_refresh_hud)
	GameState.flags_changed.connect(_refresh_hud)
	GameState.dialogue_changed.connect(_refresh_dialogue)
	GameState.fading_changed.connect(_on_fade)
	GameState.hand_changed.connect(_refresh_hud)
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
