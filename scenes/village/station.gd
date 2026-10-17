extends Node2D
## A training station: a Building with its stat-colored roof and flag, a label, and a
## Zone the player walks into to get the "Train here?" prompt (Events.station_entered).

const BUILDING_SCRIPT := preload("res://scenes/village/building.gd")
const ZONE_EXTRA_TILES := Vector2(1.6, 1.6)

@export var data: StationData
@export var size_in_tiles: Vector2 = Vector2(3.0, 3.0)

@onready var _building: StaticBody2D = $Building
@onready var _zone: Area2D = $Zone
@onready var _zone_shape: CollisionPolygon2D = $Zone/CollisionPolygon2D
@onready var _label: Label = $Label


func _ready() -> void:
	_building.size_in_tiles = size_in_tiles
	_zone_shape.polygon = BUILDING_SCRIPT.footprint_for(size_in_tiles + ZONE_EXTRA_TILES)
	_zone.body_entered.connect(_on_body_entered)
	_label.add_theme_color_override("font_outline_color", Palette.OUTLINE)
	_label.add_theme_constant_override("outline_size", 6)

	if data != null:
		_building.roof_color = data.color
		_building.flag_color = data.color
		_label.text = data.station_name
		_label.add_theme_color_override("font_color", data.color)
	var label_size: Vector2 = _label.get_minimum_size()
	_label.size = label_size
	_label.position = Vector2(-label_size.x / 2.0, -_building.height - size_in_tiles.y * 16.0 - label_size.y - 44.0)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and data != null:
		Events.station_entered.emit(data, global_position)
