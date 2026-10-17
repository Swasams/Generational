class_name StatBlock
extends Resource
## Raw (base) sub-stat values. Power (luck + will + destiny) is a flat bonus added to the
## effective value of every non-Power sub-stat. Headline = sum of a group's effective sub-stats.
## Bonds is never raised with add_stat; Relationships sets it through set_bonds_base().
## Power applies to the overall Bonds stat like any other sub-stat, but never to a
## villager's individual bond points (those live in RelationshipData).

signal stat_changed(stat_name: StringName, new_value: int)

const GROUPS: Dictionary = {
	&"magic": [&"ink", &"spirit", &"mending", &"foresight"],
	&"fitness": [&"strength", &"dexterity", &"vitality"],
	&"charisma": [&"persuasion", &"bonds", &"influence"],
	&"power": [&"luck", &"will", &"destiny"],
}
const GROUP_ORDER: Array[StringName] = [&"magic", &"fitness", &"charisma", &"power"]
const POWER := &"power"
const BONDS := &"bonds"
const HATCH_MIN: int = 1
const HATCH_MAX: int = 3

@export var base: Dictionary[StringName, int] = {}


## The "hatch roll": every sub-stat 1..3, except bonds and the Power stats start at 0.
func roll_hatch(rng: RandomNumberGenerator) -> void:
	for group in GROUP_ORDER:
		for stat in stats_in(group):
			if group == POWER or stat == BONDS:
				base[stat] = 0
			else:
				base[stat] = rng.randi_range(HATCH_MIN, HATCH_MAX)


static func stats_in(group: StringName) -> Array[StringName]:
	var out: Array[StringName] = []
	out.assign(GROUPS.get(group, []))
	return out


static func group_of(stat: StringName) -> StringName:
	for group in GROUP_ORDER:
		if GROUPS[group].has(stat):
			return group
	return &""


static func is_power_stat(stat: StringName) -> bool:
	return GROUPS[POWER].has(stat)


func get_base(stat: StringName) -> int:
	return base.get(stat, 0)


func get_power_total() -> int:
	var total: int = 0
	for stat in stats_in(POWER):
		total += get_base(stat)
	return total


func get_effective(stat: StringName) -> int:
	if is_power_stat(stat):
		return get_base(stat)
	return get_base(stat) + get_power_total()


func get_headline(group: StringName) -> int:
	var total: int = 0
	for stat in stats_in(group):
		total += get_effective(stat)
	return total


func add_stat(stat: StringName, amount: int) -> void:
	if stat == BONDS:
		push_error("StatBlock: bonds is built from relationships only; use Relationships instead")
		return

	if group_of(stat) == &"":
		push_error("StatBlock: unknown stat '%s'" % stat)
		return
	base[stat] = get_base(stat) + amount
	stat_changed.emit(stat, get_effective(stat))

	if is_power_stat(stat):
		_emit_all_non_power()


## Called by Relationships only.
func set_bonds_base(value: int) -> void:
	if get_base(BONDS) == value:
		return
	base[BONDS] = value
	stat_changed.emit(BONDS, get_effective(BONDS))


func _emit_all_non_power() -> void:
	for group in GROUP_ORDER:
		if group == POWER:
			continue
		for stat in stats_in(group):
			stat_changed.emit(stat, get_effective(stat))
