extends Control

@onready var result_title_label := $MarginContainer/PanelContainer/MarginContainer/Content/ResultTitle as Label
@onready var result_body_label := $MarginContainer/PanelContainer/MarginContainer/Content/ResultBody as Label
@onready var replay_button := $MarginContainer/PanelContainer/MarginContainer/Content/ReplayButton as Button
@onready var menu_button := $MarginContainer/PanelContainer/MarginContainer/Content/MenuButton as Button
@onready var background := $Background as ColorRect
@onready var outer_margin := $MarginContainer as MarginContainer
@onready var panel := $MarginContainer/PanelContainer as PanelContainer
@onready var content := $MarginContainer/PanelContainer/MarginContainer/Content as VBoxContainer


func _ready() -> void:
	_apply_showcase_style()
	replay_button.pressed.connect(_on_replay_button_pressed)
	menu_button.pressed.connect(_on_menu_button_pressed)
	replay_button.text = "再次试玩"
	menu_button.text = "返回菜单"
	replay_button.grab_focus()
	result_title_label.text = RunResultState.outcome_title
	var showcase_status := "展示状态：当前版本已支持从菜单到结算的完整试玩。"
	result_body_label.text = "\n".join([
		"试玩总结",
		RunResultState.outcome_text,
		"最终分数：%06d" % RunResultState.score,
		"击毁目标：%d/%d" % [RunResultState.destroyed_count, RunResultState.total_targets],
		"最高连击：x%d  连击奖励：%d" % [RunResultState.best_chain, RunResultState.chain_bonus_score],
		RunResultState.summary_text,
		showcase_status,
		"重玩：按 R 或选择再次试玩",
		"菜单：按 M、Esc 或选择返回菜单",
		RunResultState.build_text,
	])
	_layout_showcase_card()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_node_ready():
		_layout_showcase_card()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_R:
			_on_replay_button_pressed()
			get_viewport().set_input_as_handled()
		elif event.physical_keycode == KEY_M or event.physical_keycode == KEY_ESCAPE:
			_on_menu_button_pressed()
			get_viewport().set_input_as_handled()


func _on_replay_button_pressed() -> void:
	RunResultState.reset()
	get_tree().change_scene_to_file(RunResultState.GAME_SCENE_PATH)


func _on_menu_button_pressed() -> void:
	RunResultState.reset()
	get_tree().change_scene_to_file(RunResultState.MENU_SCENE_PATH)


func _apply_showcase_style() -> void:
	background.color = Color(0.025, 0.035, 0.07, 1.0)
	panel.add_theme_stylebox_override(
		"panel",
		_box_style(Color(0.055, 0.072, 0.13, 0.96), Color(0.46, 0.64, 1.0, 0.78), 2)
	)
	content.add_theme_constant_override("separation", 13)

	result_title_label.add_theme_font_size_override("font_size", 34)
	result_title_label.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0))
	result_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	result_body_label.add_theme_font_size_override("font_size", 18)
	result_body_label.add_theme_color_override("font_color", Color(0.80, 0.88, 0.98))
	result_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	replay_button.custom_minimum_size = Vector2(0.0, 46.0)
	menu_button.custom_minimum_size = Vector2(0.0, 44.0)
	_apply_button_style(replay_button, Color(0.48, 0.72, 1.0), true)
	_apply_button_style(menu_button, Color(0.55, 0.64, 0.82), false)


func _layout_showcase_card() -> void:
	var viewport_size := get_viewport_rect().size
	var narrow := viewport_size.x <= 560.0
	var horizontal_margin := 18 if narrow else 150
	var vertical_margin := 28 if narrow else 82
	outer_margin.add_theme_constant_override("margin_left", horizontal_margin)
	outer_margin.add_theme_constant_override("margin_right", horizontal_margin)
	outer_margin.add_theme_constant_override("margin_top", vertical_margin)
	outer_margin.add_theme_constant_override("margin_bottom", vertical_margin)
	result_title_label.add_theme_font_size_override("font_size", 28 if narrow else 34)
	result_body_label.add_theme_font_size_override("font_size", 16 if narrow else 18)


func _apply_button_style(button: Button, accent: Color, primary: bool) -> void:
	var fill := Color(0.08, 0.10, 0.16, 1.0).lerp(accent, 0.24 if primary else 0.10)
	button.add_theme_stylebox_override("normal", _box_style(fill, accent, 1))
	button.add_theme_stylebox_override("hover", _box_style(fill.lerp(accent, 0.20), accent, 1))
	button.add_theme_stylebox_override("pressed", _box_style(Color(0.035, 0.045, 0.075, 1.0).lerp(accent, 0.24), accent, 1))
	button.add_theme_stylebox_override("focus", _box_style(fill.lerp(accent, 0.30), accent, 2))
	button.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.04, 0.05, 0.08))
	button.add_theme_font_size_override("font_size", 17 if primary else 16)


func _box_style(fill: Color, border: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 12.0
	style.content_margin_top = 8.0
	style.content_margin_right = 12.0
	style.content_margin_bottom = 8.0
	style.shadow_size = 14
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.36)
	return style
