extends TileMapLayer
## Isometric placeholder ground. Builds its own diamond TileSet in code
## (PARCHMENT / WARM_SAND checker, MOSS border) and fills a map_size x map_size diamond.
## To use real art later: assign a TileSet with the same three tiles in the inspector
## and _build_tile_set() is skipped. The fill only needs atlas coords (0,0) (1,0) (2,0).

const TILE_W: int = 64
const TILE_H: int = 32
const SOURCE_ID: int = 0

const ATLAS_PARCHMENT := Vector2i(0, 0)
const ATLAS_SAND := Vector2i(1, 0)
const ATLAS_MOSS := Vector2i(2, 0)

@export var map_size: int = 16


func _ready() -> void:
	if tile_set == null:
		tile_set = _build_tile_set()
	_fill()


## World-space center of a tile cell.
func cell_to_world(cell: Vector2i) -> Vector2:
	return to_global(map_to_local(cell))


## World-space center of the whole map.
func get_center_world() -> Vector2:
	var mid: int = map_size / 2
	return cell_to_world(Vector2i(mid, mid))


## The four outer tips of the diamond map in world space: top, right, bottom, left.
func get_outer_corners() -> PackedVector2Array:
	var last: int = map_size - 1
	var half := Vector2(TILE_W, TILE_H) * 0.5
	return PackedVector2Array([
		to_global(map_to_local(Vector2i(0, 0)) + Vector2(0.0, -half.y)),
		to_global(map_to_local(Vector2i(last, 0)) + Vector2(half.x, 0.0)),
		to_global(map_to_local(Vector2i(last, last)) + Vector2(0.0, half.y)),
		to_global(map_to_local(Vector2i(0, last)) + Vector2(-half.x, 0.0)),
	])


func _fill() -> void:
	clear()
	for y in map_size:
		for x in map_size:
			var is_border: bool = x == 0 or y == 0 or x == map_size - 1 or y == map_size - 1
			var atlas: Vector2i = ATLAS_MOSS

			if not is_border:
				atlas = ATLAS_PARCHMENT if (x + y) % 2 == 0 else ATLAS_SAND
			set_cell(Vector2i(x, y), SOURCE_ID, atlas)


func _build_tile_set() -> TileSet:
	var new_set := TileSet.new()
	new_set.tile_shape = TileSet.TILE_SHAPE_ISOMETRIC
	new_set.tile_layout = TileSet.TILE_LAYOUT_DIAMOND_DOWN
	new_set.tile_size = Vector2i(TILE_W, TILE_H)
	var source := TileSetAtlasSource.new()
	source.texture = _build_texture([Palette.PARCHMENT, Palette.WARM_SAND, Palette.MOSS])
	source.texture_region_size = Vector2i(TILE_W, TILE_H)
	for i in 3:
		source.create_tile(Vector2i(i, 0))
	new_set.add_source(source, SOURCE_ID)
	return new_set


func _build_texture(colors: Array[Color]) -> ImageTexture:
	var image := Image.create(TILE_W * colors.size(), TILE_H, false, Image.FORMAT_RGBA8)
	image.fill(Palette.TRANSPARENT)
	for i in colors.size():
		_paint_diamond(image, i * TILE_W, colors[i])
	return ImageTexture.create_from_image(image)


func _paint_diamond(image: Image, x_offset: int, fill: Color) -> void:
	var edge := fill.blend(Color(Palette.INK_INDIGO, 0.22))
	var half_w: float = TILE_W / 2.0
	var half_h: float = TILE_H / 2.0
	for y in TILE_H:
		for x in TILE_W:
			var dx: float = absf(x + 0.5 - half_w) / half_w
			var dy: float = absf(y + 0.5 - half_h) / half_h
			var d: float = dx + dy

			if d <= 1.0:
				image.set_pixel(x_offset + x, y, fill if d < 0.9 else edge)
