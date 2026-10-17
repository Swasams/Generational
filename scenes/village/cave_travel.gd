extends Node
## Handles the outcome of the leave-village popup: "Yes" swaps to the cave scene,
## "No" nudges the player back out of the exit so it can trigger again later.

const CAVE_SCENE := preload("res://scenes/cave/cave_placeholder.tscn")
const NUDGE_DISTANCE: float = 56.0

@export var player: Node2D
@export var ground: TileMapLayer


func _ready() -> void:
	Events.cave_travel_confirmed.connect(_on_confirmed)
	Events.cave_travel_declined.connect(_on_declined)


func _on_confirmed(overlord: OverlordData) -> void:
	var cave := CAVE_SCENE.instantiate() as CavePlaceholder
	cave.overlord = overlord
	var tree := get_tree()
	var village: Node = tree.current_scene
	tree.root.add_child(cave)
	tree.current_scene = cave
	village.queue_free()


func _on_declined() -> void:
	if player == null or ground == null:
		return
	var center: Vector2 = ground.get_center_world()
	var direction := (center - player.global_position).normalized()
	player.global_position += direction * NUDGE_DISTANCE
