class_name UIFactory
extends RefCounted

const BG := Color("07112a")
const PANEL := Color("111d42e8")
const CYAN := Color("61f4e8")
const PURPLE := Color("9b7cff")
const TEXT := Color("e7fbff")
const MUTED := Color("8fa6c7")

static func ui_multiplier() -> float:
	var window_size:=DisplayServer.window_get_size()
	if window_size.x<=0:return 1.0
	return clampf(1152.0/float(window_size.x),1.0,1.8)

static func panel_style(color := PANEL, radius := 12, border_color := Color("385080")) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_width_left = 1; style.border_width_top = 1; style.border_width_right = 1; style.border_width_bottom = 1
	style.border_color = border_color
	style.corner_radius_top_left = radius; style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius; style.corner_radius_bottom_right = radius
	style.content_margin_left = 20; style.content_margin_right = 20
	style.content_margin_top = 12; style.content_margin_bottom = 12
	return style

static func style_button(button: Button, accent := CYAN) -> void:
	var multiplier:=ui_multiplier()
	button.custom_minimum_size = Vector2(300, 48)*multiplier
	button.add_theme_font_size_override("font_size", roundi(18*multiplier))
	button.add_theme_color_override("font_color", TEXT)
	button.add_theme_color_override("font_hover_color", Color("081525"))
	button.add_theme_stylebox_override("normal", panel_style(Color("132147d9"), 8, Color("30466d")))
	button.add_theme_stylebox_override("hover", panel_style(accent, 8, accent))
	button.add_theme_stylebox_override("pressed", panel_style(accent.darkened(0.2), 8, accent))
	button.add_theme_stylebox_override("disabled", panel_style(Color("10172a99"), 8, Color("202a40")))
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.focus_mode = Control.FOCUS_ALL
	button.pressed.connect(func(): AudioManager.play_sfx("click"))

static func title_label(text: String, size := 54) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", roundi(size*ui_multiplier()))
	label.add_theme_color_override("font_color", TEXT)
	label.add_theme_color_override("font_shadow_color", Color("20d9dc88"))
	label.add_theme_constant_override("shadow_offset_x", 3)
	label.add_theme_constant_override("shadow_offset_y", 3)
	return label

static func label(text: String, size := 18, color := TEXT) -> Label:
	var result := Label.new()
	result.text = text
	result.add_theme_font_size_override("font_size", roundi(size*ui_multiplier()))
	result.add_theme_color_override("font_color", color)
	return result
