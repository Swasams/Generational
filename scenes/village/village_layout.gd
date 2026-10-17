class_name VillageLayout
extends RefCounted
## Seeded placement of buildings and villager spots on the map's inner cells.
## Keeps a plaza clear around the center and two diagonal roads to the four corner exits.
## Usage: begin() → reserve_area() for fixed things (stations) → place_buildings() → place_villagers().

const BORDER_MARGIN: int = 2
const ROAD_HALF_WIDTH: int = 1
const BUILDING_MARGIN: int = 1
const MIN_BUILDING_TILES: int = 2
const MAX_BUILDING_TILES: int = 3

var building_cells: Array[Vector2i] = []
var building_sizes: Array[Vector2i] = []
var villager_cells: Array[Vector2i] = []

var _map_size: int = 16
var _clear_radius: int = 3
var _occupied: Dictionary = {}
var _rng := RandomNumberGenerator.new()


func begin(map_size: int, layout_seed: int, clear_radius: int) -> void:
	_map_size = map_size
	_clear_radius = clear_radius
	_rng.seed = layout_seed
	building_cells.clear()
	building_sizes.clear()
	villager_cells.clear()
	_occupied.clear()


## Marks a fixed footprint (plus margin) as taken so buildings and villagers avoid it.
func reserve_area(center: Vector2i, size: Vector2i) -> void:
	for cell in _footprint_cells(center, size, BUILDING_MARGIN):
		_occupied[cell] = true


func place_buildings(count: int) -> void:
	var attempts: int = 0
	while building_cells.size() < count and attempts < count * 40:
		attempts += 1
		var size := Vector2i(
			_rng.randi_range(MIN_BUILDING_TILES, MAX_BUILDING_TILES),
			_rng.randi_range(MIN_BUILDING_TILES, MAX_BUILDING_TILES),
		)
		var cell := _random_inner_cell()
		var cells := _footprint_cells(cell, size, BUILDING_MARGIN)

		if _any_blocked(cells):
			continue
		for c in cells:
			_occupied[c] = true
		building_cells.append(cell)
		building_sizes.append(size)


func place_villagers(count: int) -> void:
	var attempts: int = 0
	while villager_cells.size() < count and attempts < count * 40:
		attempts += 1
		var cell := _random_inner_cell()

		if _occupied.has(cell) or villager_cells.has(cell):
			continue
		villager_cells.append(cell)


func _random_inner_cell() -> Vector2i:
	var last: int = _map_size - 1 - BORDER_MARGIN
	return Vector2i(_rng.randi_range(BORDER_MARGIN, last), _rng.randi_range(BORDER_MARGIN, last))


func _footprint_cells(center: Vector2i, size: Vector2i, margin: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var half_x: int = ceili(size.x / 2.0) + margin
	var half_y: int = ceili(size.y / 2.0) + margin
	for dy in range(-half_y, half_y + 1):
		for dx in range(-half_x, half_x + 1):
			cells.append(center + Vector2i(dx, dy))
	return cells


func _any_blocked(cells: Array[Vector2i]) -> bool:
	for cell in cells:
		if _occupied.has(cell) or _is_reserved(cell):
			return true
	return false


## Plaza around the center, the two diagonal roads, and the border are kept free of buildings.
func _is_reserved(cell: Vector2i) -> bool:
	var last: int = _map_size - 1
	var center: int = _map_size / 2

	if cell.x < BORDER_MARGIN or cell.y < BORDER_MARGIN or cell.x > last - BORDER_MARGIN or cell.y > last - BORDER_MARGIN:
		return true

	if maxi(absi(cell.x - center), absi(cell.y - center)) <= _clear_radius:
		return true

	if absi(cell.x - cell.y) <= ROAD_HALF_WIDTH:
		return true
	return absi(cell.x + cell.y - last) <= ROAD_HALF_WIDTH
