class_name UIStyles
## Small helpers for Palette-only UI styleboxes built in code.

const CORNER_RADIUS: int = 8


static func box(bg: Color, border: Color = Palette.OUTLINE, border_width: int = 2, radius: int = CORNER_RADIUS) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.set_content_margin_all(10.0)
	return style


## INK_INDIGO on light backgrounds, PARCHMENT on dark ones.
static func text_on(bg: Color) -> Color:
	return Palette.TEXT if bg.get_luminance() > 0.45 else Palette.PARCHMENT


## Applies a solid colored look to a Button (normal/hover/pressed/focus).
static func color_button(button: Button, bg: Color, selected: bool = false) -> void:
	var border_width: int = 4 if selected else 2
	button.add_theme_stylebox_override("normal", box(bg, Palette.OUTLINE, border_width))
	button.add_theme_stylebox_override("hover", box(bg.lightened(0.15), Palette.OUTLINE, border_width))
	button.add_theme_stylebox_override("pressed", box(bg.darkened(0.2), Palette.OUTLINE, border_width))
	button.add_theme_stylebox_override("focus", box(bg, Palette.MARIGOLD, border_width))
	var text_color := text_on(bg)
	button.add_theme_color_override("font_color", text_color)
	button.add_theme_color_override("font_hover_color", text_color)
	button.add_theme_color_override("font_pressed_color", text_color)
	button.add_theme_color_override("font_focus_color", text_color)
	button.add_theme_color_override("font_hover_pressed_color", text_color)
