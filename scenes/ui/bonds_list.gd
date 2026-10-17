extends VBoxContainer
## Under Charisma > Bonds: progress toward the next Bonds point, then every villager
## you've interacted with, their bond points and talk-progress dots.

const PROGRESS_DOTS_SCRIPT := preload("res://scenes/ui/progress_dots.gd")
const INDENT: float = 44.0

var _progress_label: Label
var _rows: VBoxContainer


func _ready() -> void:
	add_theme_constant_override("separation", 4)
	_progress_label = Label.new()
	_progress_label.add_theme_color_override("font_color", Palette.CHARISMA)
	_progress_label.add_theme_font_size_override("font_size", 15)
	add_child(_progress_label)
	_rows = VBoxContainer.new()
	_rows.add_theme_constant_override("separation", 2)
	add_child(_rows)
	Relationships.relationship_changed.connect(func(_id: StringName, _points: int) -> void: refresh())
	refresh()


func refresh() -> void:
	var total: int = Relationships.total_bond_points()
	var target: int = Relationships.next_bonds_target()
	_progress_label.text = "        %d/%d → Bonds %d" % [total, target, Relationships.bonds_base() + 1]
	for child in _rows.get_children():
		child.queue_free()

	if Relationships.by_villager.is_empty():
		_rows.add_child(_make_label("        No one yet. Talk to a villager."))
		return
	for villager_id in Relationships.by_villager:
		_rows.add_child(_make_row(Relationships.by_villager[villager_id]))


func _make_row(relationship: RelationshipData) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(INDENT, 0.0)
	row.add_child(spacer)

	var name_label := _make_label(relationship.villager_name)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_label)

	var dots := Control.new()
	dots.set_script(PROGRESS_DOTS_SCRIPT)
	dots.set("total", RelationshipData.TALKS_PER_POINT)
	dots.set("filled", relationship.talk_progress())
	dots.set("color", Palette.CHARISMA)
	dots.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(dots)

	var points_label := _make_label("Bond %d" % relationship.bond_points())
	points_label.add_theme_color_override("font_color", Palette.CHARISMA)
	points_label.custom_minimum_size = Vector2(70.0, 0.0)
	points_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(points_label)
	return row


func _make_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 15)
	return label
