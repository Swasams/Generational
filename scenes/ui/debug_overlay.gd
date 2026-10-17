extends CanvasLayer
## Top-left debug readout: world year, years left, age, FPS, trinkets, bond points.
## Debug keys: Y +1 year (Clock), G +5 trinkets, P +1 luck. Reads state; never owns it.

const DEBUG_TRINKETS: int = 5

@onready var _readout: Label = %Readout


func _process(_delta: float) -> void:
	_readout.text = "Year %d / %d\nYears left: %d\nAge: %d\nFPS: %d\nTrinkets: %d\nBond points: %d\n[Y] +1 year  [G] +5 trinkets  [P] +1 luck" % [
		Clock.world_year,
		Clock.MAX_YEAR,
		Clock.years_left(),
		Clock.age,
		Engine.get_frames_per_second(),
		PlayerState.trinkets,
		Relationships.total_bond_points(),
	]


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_add_trinkets"):
		PlayerState.add_trinkets(DEBUG_TRINKETS)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("debug_add_luck"):
		PlayerState.stats.add_stat(&"luck", 1)
		get_viewport().set_input_as_handled()
