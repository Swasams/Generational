extends Node
## Asks "Leave the village toward X?" when the player walks into a cave exit and
## answers with Events.cave_travel_confirmed / cave_travel_declined.

@export var confirm_popup: ConfirmPopup

var _busy: bool = false


func _ready() -> void:
	Events.cave_exit_entered.connect(_on_cave_exit_entered)


func _on_cave_exit_entered(overlord: OverlordData) -> void:
	if _busy:
		return
	_busy = true
	var yes: bool = await confirm_popup.ask("Leave the village toward %s?" % overlord.display_name)
	_busy = false

	if yes:
		Events.cave_travel_confirmed.emit(overlord)
	else:
		Events.cave_travel_declined.emit()
