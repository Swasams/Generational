class_name RelationshipData
extends Resource
## The player's relationship with one villager. Bond points = gifts + floor(talks / 3).
## Per-villager bond points are raw: Power never touches them. Power only lifts the
## overall Bonds stat (see StatBlock.get_effective).

const TALKS_PER_POINT: int = 3

@export var villager_name: String = "Villager"
@export var talks: int = 0
@export var gifts: int = 0


func bond_points() -> int:
	return gifts + talks / TALKS_PER_POINT


## Talks accumulated toward the next bond point (0..2).
func talk_progress() -> int:
	return talks % TALKS_PER_POINT
