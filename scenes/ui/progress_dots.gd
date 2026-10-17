extends Control
## A row of dots showing progress toward the next point (e.g. talks 0..2 of 3).

const DOT_RADIUS: float = 5.0
const DOT_SPACING: float = 15.0

@export var total: int = 3:
	set(value):
		total = maxi(value, 1)
		_update_size()
		queue_redraw()
@export var filled: int = 0:
	set(value):
		filled = clampi(value, 0, total)
		queue_redraw()
@export var color: Color = Palette.CHARISMA:
	set(value):
		color = value
		queue_redraw()


func _ready() -> void:
	_update_size()


func _update_size() -> void:
	custom_minimum_size = Vector2(total * DOT_SPACING, DOT_RADIUS * 2.0 + 2.0)


func _draw() -> void:
	for i in total:
		var center := Vector2(DOT_SPACING * i + DOT_RADIUS + 1.0, size.y / 2.0)

		if i < filled:
			draw_circle(center, DOT_RADIUS, color)
		draw_arc(center, DOT_RADIUS, 0.0, TAU, 16, Palette.OUTLINE, 1.5, true)
