class_name VillagerData
extends Resource
## A villager: unique id, placeholder name, the overlord they follow,
## and whether the player has already talked to them this year.

@export var id: StringName = &"villager"
@export var villager_name: String = "Villager"
@export var overlord: OverlordData
var talked_this_year: bool = false
