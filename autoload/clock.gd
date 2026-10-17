extends Node
## The 1000-year timeline and the current character's age.
## Debug: press Y (action "debug_advance_year") to advance one year.

signal year_advanced(world_year: int, age: int)

const MAX_YEAR: int = 1000

var world_year: int = 0
var age: int = 0


func advance_year() -> void:
	if world_year >= MAX_YEAR:
		return
	world_year += 1
	age += 1
	year_advanced.emit(world_year, age)


func years_left() -> int:
	return MAX_YEAR - world_year


## Call when a new heir takes over; the world keeps counting, the age resets.
func start_new_character(starting_age: int = 0) -> void:
	age = starting_age
	year_advanced.emit(world_year, age)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_advance_year"):
		advance_year()
		get_viewport().set_input_as_handled()
