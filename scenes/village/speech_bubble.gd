extends Node2D
## A small PARCHMENT speech bubble with an INK_INDIGO outline that shows text for a few seconds.
## Child of a villager; the node's origin is where the bubble's tail points.

const PADDING := Vector2(12.0, 8.0)
const TAIL_HEIGHT: float = 10.0
const CORNER_RADIUS: int = 8

@export var show_seconds: float = 2.5

@onready var _label: Label = $Label
@onready var _timer: Timer = $Timer

var _style := StyleBoxFlat.new()


func _ready() -> void:
	visible = false
	_timer.one_shot = true
	_timer.timeout.connect(hide)
	_label.add_theme_color_override("font_color", Palette.TEXT)
	_style.bg_color = Palette.PARCHMENT
	_style.border_color = Palette.OUTLINE
	_style.set_border_width_all(2)
	_style.set_corner_radius_all(CORNER_RADIUS)


func show_text(text: String) -> void:
	_label.text = text
	var text_size: Vector2 = _label.get_minimum_size()
	_label.size = text_size
	_label.position = Vector2(-text_size.x / 2.0, -TAIL_HEIGHT - PADDING.y - text_size.y)
	visible = true
	_timer.start(show_seconds)
	queue_redraw()


func _draw() -> void:
	var rect := Rect2(_label.position - PADDING, _label.size + PADDING * 2.0)
	draw_style_box(_style, rect)
	var tail := PackedVector2Array([
		Vector2(-8.0, rect.end.y - 1.0),
		Vector2(8.0, rect.end.y - 1.0),
		Vector2(0.0, rect.end.y + TAIL_HEIGHT),
	])
	draw_colored_polygon(tail, Palette.PARCHMENT)
	draw_polyline(PackedVector2Array([tail[0], tail[2], tail[1]]), Palette.OUTLINE, 2.0, true)
