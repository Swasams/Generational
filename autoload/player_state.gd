extends Node
## The current daughter's state: her StatBlock and her trinkets.

signal trinkets_changed(count: int)

const STARTING_TRINKETS: int = 5

var stats: StatBlock = StatBlock.new()
var trinkets: int = STARTING_TRINKETS:
	set(value):
		trinkets = maxi(value, 0)
		trinkets_changed.emit(trinkets)


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	stats.roll_hatch(rng)


func add_trinkets(amount: int) -> void:
	trinkets += amount


## Returns false (and spends nothing) when there are no trinkets left.
func spend_trinket() -> bool:
	if trinkets <= 0:
		return false
	trinkets -= 1
	return true
