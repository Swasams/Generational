extends Node2D
## Draws a capsule body with an INK_INDIGO outline and a soft ground shadow.
## The node's origin is at the feet. Used by Player and Villager.

const OUTLINE_WIDTH: float = 2.0
const ARC_STEPS: int = 12
const ELLIPSE_STEPS: int = 24

@export var body_color: Color = Palette.MARIGOLD:
	set(value):
		body_color = value
		queue_redraw()
@export var radius: float = 11.0
@export var height: float = 46.0


func _draw() -> void:
	_draw_shadow()
	var points := _capsule_points()
	draw_colored_polygon(points, body_color)
	var outline := PackedVector2Array(points)
	outline.append(points[0])
	draw_polyline(outline, Palette.OUTLINE, OUTLINE_WIDTH, true)


func _draw_shadow() -> void:
	# Two stacked ellipses, a wide faint one under a tighter one, for a soft edge.
	draw_colored_polygon(_ellipse(radius * 1.7, radius * 0.7), Color(Palette.INK_INDIGO, 0.12))
	draw_colored_polygon(_ellipse(radius * 1.3, radius * 0.5), Palette.SHADOW)


func _ellipse(rx: float, ry: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in ELLIPSE_STEPS:
		var t: float = TAU * i / float(ELLIPSE_STEPS)
		points.append(Vector2(cos(t) * rx, sin(t) * ry))
	return points


func _capsule_points() -> PackedVector2Array:
	var points := PackedVector2Array()
	var bottom_center := Vector2(0.0, -radius - 2.0)
	var top_center := Vector2(0.0, -height + radius)
	# Bottom arc going under (left to right), then top arc going over (right to left).
	for i in ARC_STEPS + 1:
		var t: float = PI + PI * i / float(ARC_STEPS)
		points.append(bottom_center + Vector2(cos(t) * radius, -sin(t) * radius))
	for i in ARC_STEPS + 1:
		var t: float = PI * i / float(ARC_STEPS)
		points.append(top_center + Vector2(cos(t) * radius, -sin(t) * radius))
	return points
