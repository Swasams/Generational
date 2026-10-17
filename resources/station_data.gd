class_name StationData
extends Resource
## A training station: a year spent here applies `gains` (stat id -> amount).

@export var station_name: String = "Station"
## Stat group the station mainly trains (magic / fitness / charisma); drives the roof color.
@export var group: StringName = &"magic"
@export var color: Color = Palette.MAGIC
@export var gains: Dictionary[StringName, int] = {}
