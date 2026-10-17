extends Node
## Asks "Train here? (1 year)" when the player enters a station zone, runs the training,
## shows the result, and nudges the player back out so the zone can trigger again.

const NUDGE_DISTANCE: float = 72.0

@export var confirm_popup: ConfirmPopup
@export var message_popup: MessagePopup
@export var player: Node2D

var _busy: bool = false


func _ready() -> void:
	Events.station_entered.connect(_on_station_entered)


func _on_station_entered(station: StationData, station_position: Vector2) -> void:
	if _busy:
		return
	_busy = true
	var yes: bool = await confirm_popup.ask("Train at the %s? (1 year)" % station.station_name)
	_push_player_away(station_position)

	if yes:
		var summary: String = Training.train(station)
		await message_popup.show_message(summary)
	_busy = false


func _push_player_away(from: Vector2) -> void:
	if player == null:
		return
	var direction := (player.global_position - from).normalized()

	if direction == Vector2.ZERO:
		direction = Vector2.DOWN
	player.global_position += direction * NUDGE_DISTANCE
