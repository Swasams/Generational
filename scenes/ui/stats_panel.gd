extends CanvasLayer
## Stats panel: four headline rows that expand into sub-stats; Bonds expands into the
## relationship list. Toggle with Tab or the top-right stats box. Updates live from
## PlayerState.stats.stat_changed, flashing rows and floating "+N" when a value rises.

const STAT_ROW_SCRIPT := preload("res://scenes/ui/stat_row.gd")
const BONDS_LIST_SCRIPT := preload("res://scenes/ui/bonds_list.gd")
const COLORS: Dictionary = {
	&"magic": Palette.MAGIC, &"fitness": Palette.FITNESS,
	&"charisma": Palette.CHARISMA, &"power": Palette.POWER,
}
const FLOAT_RISE: float = 28.0
const FLOAT_SECONDS: float = 0.9

@onready var _panel: PanelContainer = %Panel
@onready var _rows_box: VBoxContainer = %Rows
@onready var _float_layer: Control = %FloatLayer

var _headline_rows: Dictionary = {}
var _stat_rows: Dictionary = {}
var _group_boxes: Dictionary = {}
var _bonds_list: VBoxContainer
var _last_headline: Dictionary = {}
var _last_stat: Dictionary = {}


func _ready() -> void:
	visible = false
	for group in StatBlock.GROUP_ORDER:
		_build_group(group)
	_refresh_all()
	PlayerState.stats.stat_changed.connect(_on_stat_changed)
	Events.stats_box_clicked.connect(toggle)


func toggle() -> void:
	visible = not visible


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_stats"):
		toggle()
		get_viewport().set_input_as_handled()


func _build_group(group: StringName) -> void:
	var color: Color = COLORS[group]
	var headline: PanelContainer = _make_row(String(group).capitalize(), color, true, 0, 20)
	_rows_box.add_child(headline)
	_headline_rows[group] = headline

	var sub_box := VBoxContainer.new()
	sub_box.visible = false
	sub_box.add_theme_constant_override("separation", 0)
	_rows_box.add_child(sub_box)
	_group_boxes[group] = sub_box
	headline.pressed.connect(func() -> void: _toggle_box(sub_box, headline))

	for stat in StatBlock.stats_in(group):
		var is_bonds: bool = stat == StatBlock.BONDS
		var row: PanelContainer = _make_row(String(stat).capitalize(), color, is_bonds, 22, 16)
		sub_box.add_child(row)
		_stat_rows[stat] = row

		if is_bonds:
			_bonds_list = VBoxContainer.new()
			_bonds_list.set_script(BONDS_LIST_SCRIPT)
			_bonds_list.visible = false
			sub_box.add_child(_bonds_list)
			row.pressed.connect(func() -> void: _toggle_box(_bonds_list, row))


func _make_row(title: String, color: Color, tappable: bool, indent: int, font_size: int) -> PanelContainer:
	var row := PanelContainer.new()
	row.set_script(STAT_ROW_SCRIPT)
	row.call("setup", title, color, tappable, indent, font_size)
	return row


func _toggle_box(box: Control, row: Control) -> void:
	box.visible = not box.visible
	row.call("set_expanded", box.visible)
	_panel.reset_size()


func _refresh_all() -> void:
	for group in StatBlock.GROUP_ORDER:
		var headline_value: int = PlayerState.stats.get_headline(group)
		_headline_rows[group].call("set_value", headline_value)
		_last_headline[group] = headline_value
		for stat in StatBlock.stats_in(group):
			_refresh_stat_row(stat)
			_last_stat[stat] = PlayerState.stats.get_effective(stat)


func _refresh_stat_row(stat: StringName) -> void:
	var row: PanelContainer = _stat_rows[stat]
	row.call("set_value", PlayerState.stats.get_effective(stat))
	var power: int = PlayerState.stats.get_power_total()

	if power > 0 and not StatBlock.is_power_stat(stat):
		row.call("set_detail", "base %d + power %d" % [PlayerState.stats.get_base(stat), power])
	else:
		row.call("set_detail", "")


func _on_stat_changed(stat: StringName, new_value: int) -> void:
	var delta: int = new_value - int(_last_stat.get(stat, new_value))
	_last_stat[stat] = new_value
	_refresh_stat_row(stat)
	var row: PanelContainer = _stat_rows[stat]

	if delta > 0 and row.is_visible_in_tree():
		_celebrate(row, delta)

	var group: StringName = StatBlock.group_of(stat)
	var headline_value: int = PlayerState.stats.get_headline(group)
	var headline_delta: int = headline_value - int(_last_headline.get(group, headline_value))
	_last_headline[group] = headline_value
	var headline: PanelContainer = _headline_rows[group]
	headline.call("set_value", headline_value)

	if headline_delta > 0 and visible:
		_celebrate(headline, headline_delta)


func _celebrate(row: PanelContainer, delta: int) -> void:
	row.call("flash")
	var label := Label.new()
	label.text = "+%d" % delta
	label.add_theme_color_override("font_color", row.get("color"))
	label.add_theme_color_override("font_outline_color", Palette.OUTLINE)
	label.add_theme_constant_override("outline_size", 4)
	label.add_theme_font_size_override("font_size", 20)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_float_layer.add_child(label)
	label.position = row.global_position + Vector2(row.size.x - 60.0, -4.0)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - FLOAT_RISE, FLOAT_SECONDS)
	tween.tween_property(label, "modulate:a", 0.0, FLOAT_SECONDS).set_delay(FLOAT_SECONDS * 0.4)
	tween.chain().tween_callback(label.queue_free)
