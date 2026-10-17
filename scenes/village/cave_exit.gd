extends Area2D
## A cave mouth at the village edge, tinted toward its overlord's color and labeled.
## When the player's body enters, emits Events.cave_exit_entered(overlord).

const TINT_AMOUNT: float = 0.45
const ARC_STEPS: int = 16
const OUTLINE_WIDTH: float = 2.0
const SHADOW_OFFSET := Vector2(10.0, 6.0)

@export var overlord: OverlordData
@export var arch_width: float = 60.0
@export var arch_height: float = 70.0

@onready var _label: Label = $Label


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_label.add_theme_color_override("font_outline_color", Palette.OUTLINE)
	_label.add_theme_constant_override("outline_size", 6)

	if overlord != null:
		_label.text = overlord.display_name
		_label.add_theme_color_override("font_color", overlord.color)
	var label_size: Vector2 = _label.get_minimum_size()
	_label.size = label_size
	_label.position = Vector2(-label_size.x / 2.0, -arch_height - label_size.y - 6.0)
	queue_redraw()


func _draw() -> void:
	var tint: Color = Palette.CAVE_MOUTH

	if overlord != null:
		tint = Palette.CAVE_MOUTH.lerp(overlord.color, TINT_AMOUNT)
	var half_w: float = arch_width / 2.0
	var outer := _arch_points(half_w, arch_height)
	var inner := _arch_points(half_w - 10.0, arch_height - 10.0)

	var shadow := PackedVector2Array()
	for p in outer:
		shadow.append(p + SHADOW_OFFSET)
	draw_colored_polygon(shadow, Palette.SHADOW)
	draw_colored_polygon(outer, tint)
	draw_colored_polygon(inner, Palette.CAVE_MOUTH.darkened(0.5))
	var closed := PackedVector2Array(outer)
	closed.append(outer[0])
	draw_polyline(closed, Palette.OUTLINE, OUTLINE_WIDTH, true)


## A rounded arch standing on y = 0, from the left foot over the top to the right foot.
func _arch_points(half_w: float, h: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	var center_y: float = -(h - half_w)
	points.append(Vector2(-half_w, 0.0))
	for i in ARC_STEPS + 1:
		var t: float = PI + PI * i / float(ARC_STEPS)
		points.append(Vector2(cos(t) * half_w, center_y + sin(t) * half_w))
	points.append(Vector2(half_w, 0.0))
	return points


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and overlord != null:
		Events.cave_exit_entered.emit(overlord)
