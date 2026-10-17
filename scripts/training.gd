class_name Training
## Spending a year at a station: apply its gains, roll the Luck bonus, advance the Clock.
## Luck bonus chance = LUCK_CHANCE_PER_POINT x effective luck; one gained stat gets +1 extra.

const LUCK_CHANCE_PER_POINT: float = 0.05

## Debug override: set to true to force the Luck bonus on the next training.
static var force_luck: bool = false


static func train(station: StationData) -> String:
	var gains: Dictionary[StringName, int] = {}
	for stat in station.gains:
		gains[stat] = station.gains[stat]

	var lucky_stat: StringName = &""
	var chance: float = LUCK_CHANCE_PER_POINT * PlayerState.stats.get_effective(&"luck")

	if not gains.is_empty() and (force_luck or randf() < chance):
		lucky_stat = gains.keys().pick_random()
		gains[lucky_stat] += 1
		force_luck = false

	for stat in gains:
		PlayerState.stats.add_stat(stat, gains[stat])
	Clock.advance_year()

	var parts := PackedStringArray()
	for stat in gains:
		parts.append("%s +%d" % [String(stat).capitalize(), gains[stat]])
	var summary: String = "A year at the %s…\n%s" % [station.station_name, ", ".join(parts)]

	if lucky_stat != &"":
		summary += "\nLuck smiled on you: %s got +1 extra." % String(lucky_stat).capitalize()
	Events.training_completed.emit(station, summary)
	return summary
