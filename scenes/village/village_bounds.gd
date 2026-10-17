extends StaticBody2D
## Invisible walls along the outer edge of the isometric ground so nobody walks off the map.
## Attach to a StaticBody2D sibling of the Ground TileMapLayer and point `ground` at it.

@export var ground: TileMapLayer


func _ready() -> void:
	if ground == null or not ground.has_method("get_outer_corners"):
		push_warning("VillageBounds: no ground assigned")
		return
	var corners: PackedVector2Array = ground.get_outer_corners()
	for i in corners.size():
		var segment := SegmentShape2D.new()
		segment.a = to_local(corners[i])
		segment.b = to_local(corners[(i + 1) % corners.size()])
		var shape := CollisionShape2D.new()
		shape.shape = segment
		add_child(shape)
