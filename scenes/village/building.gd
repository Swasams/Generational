extends StaticBody2D
## Placeholder isometric box. The footprint is a diamond measured in tiles and the
## collision polygon matches it. Origin is the center of the footprint (for Y-sorting).
## Optional roof_color / flag_color let stations show their stat color.

const TILE_X := Vector2(32.0, 16.0)   # one tile step along the map's x axis
const TILE_Y := Vector2(-32.0, 16.0)  # one tile step along the map's y axis
const SHADOW_OFFSET := Vector2(16.0, 8.0)
const OUTLINE_WIDTH: float = 2.0
const FLAG_POLE: float = 34.0
const FLAG_SIZE := Vector2(22.0, 14.0)

@export var size_in_tiles: Vector2 = Vector2(2.0, 2.0)
@export var height: float = 64.0
@export var color: Color = Palette.TERRACOTTA
## Transparent = use the wall color for the roof.
@export var roof_color: Color = Palette.TRANSPARENT
## Transparent = no flag.
@export var flag_color: Color = Palette.TRANSPARENT


func _ready() -> void:
	var collider := CollisionPolygon2D.new()
	collider.polygon = footprint_for(size_in_tiles)
	add_child(collider)
	queue_redraw()


## Footprint corners for a diamond of `size` tiles: top, right, bottom, left.
static func footprint_for(size: Vector2) -> PackedVector2Array:
	var a := TILE_X * size.x * 0.5
	var b := TILE_Y * size.y * 0.5
	return PackedVector2Array([-a - b, a - b, a + b, -a + b])


func get_footprint() -> PackedVector2Array:
	return footprint_for(size_in_tiles)


func _draw() -> void:
	var foot := get_footprint()
	var lift := Vector2(0.0, -height)
	var top := foot[0]
	var right := foot[1]
	var bottom := foot[2]
	var left := foot[3]

	draw_colored_polygon(_shift(foot, SHADOW_OFFSET), Palette.SHADOW)

	var left_face := PackedVector2Array([left, bottom, bottom + lift, left + lift])
	var right_face := PackedVector2Array([bottom, right, right + lift, bottom + lift])
	var roof := _shift(foot, lift)
	draw_colored_polygon(left_face, color.darkened(0.15))
	draw_colored_polygon(right_face, color.darkened(0.3))
	draw_colored_polygon(roof, roof_color if roof_color.a > 0.0 else color.lightened(0.08))
	_outline(left_face)
	_outline(right_face)
	_outline(roof)

	if flag_color.a > 0.0:
		_draw_flag(top + lift)


func _draw_flag(base: Vector2) -> void:
	var tip := base + Vector2(0.0, -FLAG_POLE)
	draw_line(base, tip, Palette.OUTLINE, 3.0, true)
	var flag := PackedVector2Array([tip, tip + Vector2(FLAG_SIZE.x, FLAG_SIZE.y / 2.0), tip + Vector2(0.0, FLAG_SIZE.y)])
	draw_colored_polygon(flag, flag_color)
	_outline(flag)


func _shift(points: PackedVector2Array, offset: Vector2) -> PackedVector2Array:
	var shifted := PackedVector2Array()
	for p in points:
		shifted.append(p + offset)
	return shifted


func _outline(points: PackedVector2Array) -> void:
	var closed := PackedVector2Array(points)
	closed.append(points[0])
	draw_polyline(closed, Palette.OUTLINE, OUTLINE_WIDTH, true)
