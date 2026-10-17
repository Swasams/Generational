extends CanvasLayer
## Top-right stats box: a PARCHMENT panel with one line per headline stat in its color.
## Tapping it emits Events.stats_box_clicked (toggles the stats panel). Touch friendly.

const COLORS: Dictionary = {
	&"magic": Palette.MAGIC, &"fitness": Palette.FITNESS,
	&"charisma": Palette.CHARISMA, &"power": Palette.POWER,
}

@onready var _panel: PanelContainer = %Panel
@onready var _lines: VBoxContainer = %Lines

var _labels: Dictionary = {}
var _normal_style := UIStyles.box(Palette.PARCHMENT, Palette.OUTLINE, 3, 12)
var _hover_style := UIStyles.box(Palette.PARCHMENT, Palette.MARIGOLD, 3, 12)


func _ready() -> void:
	_panel.add_theme_stylebox_override("panel", _normal_style)
	_panel.gui_input.connect(_on_panel_gui_input)
	_panel.mouse_entered.connect(func() -> void: _panel.add_theme_stylebox_override("panel", _hover_style))
	_panel.mouse_exited.connect(func() -> void: _panel.add_theme_stylebox_override("panel", _normal_style))
	for group in StatBlock.GROUP_ORDER:
		_add_line(group)
	PlayerState.stats.stat_changed.connect(_on_stat_changed)
	_refresh_all()


func _add_line(group: StringName) -> void:
	var label := Label.new()
	label.add_theme_color_override("font_color", COLORS[group])
	label.add_theme_font_size_override("font_size", 20)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lines.add_child(label)
	_labels[group] = label


func _refresh_all() -> void:
	for group in StatBlock.GROUP_ORDER:
		_refresh(group)


func _refresh(group: StringName) -> void:
	var label: Label = _labels[group]
	label.text = "%s  %d" % [String(group).capitalize(), PlayerState.stats.get_headline(group)]


func _on_stat_changed(stat: StringName, _value: int) -> void:
	_refresh(StatBlock.group_of(stat))


func _on_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton

		if mouse.button_index == MOUSE_BUTTON_LEFT and mouse.pressed:
			Events.stats_box_clicked.emit()
			_panel.accept_event()
