class_name TitleScreen
extends Control

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	layout_mode = 1
	Art.backdrop(self, "res://assets/art/title.png")
	var stars := Art.backdrop(self, "res://assets/art/title-stars.png")
	stars.modulate = Color(1, 1, 1, 0.25)
	var tw := create_tween()
	tw.set_loops()
	tw.set_trans(Tween.TRANS_SINE)
	tw.tween_property(stars, "modulate:a", 0.45, 1.6)
	tw.tween_property(stars, "modulate:a", 0.18, 1.6)

	var copy := VBoxContainer.new()
	copy.layout_mode = 1
	copy.set_anchors_preset(Control.PRESET_CENTER)
	copy.offset_left = -280
	copy.offset_right = 280
	copy.offset_top = 80
	copy.offset_bottom = 280
	copy.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(copy)

	var title := Label.new()
	title.text = "ほししおの台所"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Art.GOLD)
	copy.add_child(title)

	var tag := Label.new()
	tag.text = "夜の島で、月あかりポタージュをつくる。"
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag.add_theme_font_size_override("font_size", 16)
	tag.add_theme_color_override("font_color", Art.CREAM)
	copy.add_child(tag)

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 12)
	copy.add_child(actions)

	var start := Button.new()
	start.text = "はじめる"
	start.add_theme_stylebox_override("normal", Art.primary_style())
	start.add_theme_stylebox_override("hover", Art.primary_style())
	start.add_theme_color_override("font_color", Art.NAVY)
	start.pressed.connect(func() -> void: GameState.start_new())
	actions.add_child(start)

	if GameState.has_save:
		var cont := Button.new()
		cont.text = "つづきから"
		cont.pressed.connect(func() -> void: GameState.continue_game())
		actions.add_child(cont)

	var credit := Label.new()
	credit.text = "クリックして、気になるところを探してね。失敗はないよ。"
	credit.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	credit.add_theme_font_size_override("font_size", 13)
	credit.add_theme_color_override("font_color", Color(0.957, 0.937, 0.894, 0.75))
	copy.add_child(credit)
