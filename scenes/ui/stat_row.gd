extends PanelContainer
## One row in the stats panel: colored name on the left, value on the right.
## Tappable rows emit `pressed`. `flash()` tints the row briefly when the value rises.

signal pressed()

const FLASH_SECONDS: float = 0.7

var color: Color = Palette.MARIGOLD

var _name_label: Label
var _value_label: Label
var _detail_label: Label
var _arrow_label: Label
var _style := StyleBoxFlat.new()
var _flash_tween: Tween


func setup(title: String, row_color: Color, tappable: bool, indent: int = 0, font_size: int = 18) -> void:
	color = row_color
	_style.bg_color = Palette.TRANSPARENT
	_style.set_corner_radius_all(6)
	_style.set_content_margin_all(6.0)
	_style.content_margin_left = 6.0 + indent
	add_theme_stylebox_override("panel", _style)
	mouse_filter = Control.MOUSE_FILTER_STOP if tappable else Control.MOUSE_FILTER_IGNORE

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(row)

	_arrow_label = Label.new()
	_arrow_label.text = ">" if tappable else " "
	_arrow_label.add_theme_font_size_override("font_size", font_size)
	_arrow_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(_arrow_label)

	_name_label = Label.new()
	_name_label.text = title
	_name_label.add_theme_color_override("font_color", row_color)
	_name_label.add_theme_font_size_override("font_size", font_size)
	_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(_name_label)

	_detail_label = Label.new()
	_detail_label.add_theme_font_size_override("font_size", 13)
	_detail_label.add_theme_color_override("font_color", Color(Palette.TEXT, 0.7))
	_detail_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(_detail_label)

	_value_label = Label.new()
	_value_label.custom_minimum_size = Vector2(40.0, 0.0)
	_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_value_label.add_theme_font_size_override("font_size", font_size)
	_value_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(_value_label)

	if tappable:
		gui_input.connect(_on_gui_input)


func set_value(value: int) -> void:
	_value_label.text = str(value)


func set_detail(text: String) -> void:
	_detail_label.text = text


func set_expanded(expanded: bool) -> void:
	_arrow_label.text = "v" if expanded else ">"


func flash() -> void:
	if _flash_tween != null:
		_flash_tween.kill()
	_style.bg_color = Color(color, 0.45)
	_flash_tween = create_tween()
	_flash_tween.tween_method(_set_flash_alpha, 0.45, 0.0, FLASH_SECONDS)


func _set_flash_alpha(alpha: float) -> void:
	_style.bg_color = Color(color, alpha)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton

		if mouse.button_index == MOUSE_BUTTON_LEFT and mouse.pressed:
			pressed.emit()
			accept_event()
