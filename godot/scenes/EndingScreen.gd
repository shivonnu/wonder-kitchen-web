class_name EndingScreen
extends Control

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	layout_mode = 1
	Art.backdrop(self, "res://assets/art/ending.png")
	Art.sprite(self, "res://assets/art/shion-wave.png", 40, 46, 12, 26, true, true, 1.25, true)

	var copy := VBoxContainer.new()
	copy.layout_mode = 1
	copy.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	copy.offset_top = -180
	copy.offset_bottom = -16
	copy.offset_left = 40
	copy.offset_right = -40
	copy.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(copy)

	var title := Label.new()
	title.text = "おしまい"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Art.GOLD)
	copy.add_child(title)

	var tag := Label.new()
	tag.text = "しおんは空になった器を抱えて、窓の外の月に手を振った。星しおの島の夜は、まだ続く。"
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tag.add_theme_color_override("font_color", Art.CREAM)
	copy.add_child(tag)

	var back := Button.new()
	back.text = "タイトルへ"
	back.pressed.connect(func() -> void: GameState.reset())
	copy.add_child(back)
