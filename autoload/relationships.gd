extends Node
## Every villager the player has talked to or gifted, keyed by villager id.
## Total bond points across all relationships / POINTS_PER_BONDS = the base Bonds stat.

signal relationship_changed(villager_id: StringName, bond_points: int)

const POINTS_PER_BONDS: int = 5

var by_villager: Dictionary[StringName, RelationshipData] = {}


func record_talk(villager_id: StringName, villager_name: String) -> void:
	var relationship := _get_or_create(villager_id, villager_name)
	relationship.talks += 1
	_after_change(villager_id, relationship)


func record_gift(villager_id: StringName, villager_name: String) -> void:
	var relationship := _get_or_create(villager_id, villager_name)
	relationship.gifts += 1
	_after_change(villager_id, relationship)


## Null until the player has interacted with that villager.
func get_relationship(villager_id: StringName) -> RelationshipData:
	return by_villager.get(villager_id)


func total_bond_points() -> int:
	var total: int = 0
	for relationship in by_villager.values():
		total += relationship.bond_points()
	return total


func bonds_base() -> int:
	return total_bond_points() / POINTS_PER_BONDS


## Total bond points needed for the next Bonds point.
func next_bonds_target() -> int:
	return (bonds_base() + 1) * POINTS_PER_BONDS


func _get_or_create(villager_id: StringName, villager_name: String) -> RelationshipData:
	if not by_villager.has(villager_id):
		var relationship := RelationshipData.new()
		relationship.villager_name = villager_name
		by_villager[villager_id] = relationship
	return by_villager[villager_id]


func _after_change(villager_id: StringName, relationship: RelationshipData) -> void:
	PlayerState.stats.set_bonds_base(bonds_base())
	relationship_changed.emit(villager_id, relationship.bond_points())
