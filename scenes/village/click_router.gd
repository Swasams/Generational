extends Node2D
## Turns taps/clicks into world signals: a villager under the pointer emits
## Events.villager_clicked, anything else emits Events.ground_clicked.
## Touch works through Godot's "emulate mouse from touch" (on by default),
## so only mouse buttons are handled here. Villager click areas live on physics layer 2.

const VILLAGER_LAYER_MASK: int = 2


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton

		if mouse.button_index == MOUSE_BUTTON_LEFT and mouse.pressed:
			_handle_tap(get_global_mouse_position())
			get_viewport().set_input_as_handled()


func _handle_tap(world_position: Vector2) -> void:
	var query := PhysicsPointQueryParameters2D.new()
	query.position = world_position
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = VILLAGER_LAYER_MASK
	var hits: Array[Dictionary] = get_world_2d().direct_space_state.intersect_point(query, 1)

	if hits.is_empty():
		Events.ground_clicked.emit(world_position)
		return
	var area := hits[0]["collider"] as Area2D

	if area != null:
		Events.villager_clicked.emit(area.get_parent() as Node2D)
