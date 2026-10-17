extends Node2D
## Builds the village: reserves the station spots, generates a seeded layout (VillageLayout),
## then spawns stations, buildings, villagers and the four corner cave exits under World.
## The hand-made VillagerData in `villagers` spawn first; the rest get placeholder names.

const BUILDING_SCENE := preload("res://scenes/village/building.tscn")
const VILLAGER_SCENE := preload("res://scenes/village/villager.tscn")
const CAVE_EXIT_SCENE := preload("res://scenes/village/cave_exit.tscn")
const STATION_SCENE := preload("res://scenes/village/station.tscn")
const STATION_SIZE := Vector2i(3, 3)

const PLACEHOLDER_NAMES: Array[String] = [
	"Ponni", "Kumar", "Lakshmi", "Murugan", "Devi", "Sundar", "Kamala", "Raja",
	"Priya", "Velu", "Amutha", "Ganesh", "Malar", "Siva", "Rani", "Bala",
	"Nila", "Karthik", "Vasuki", "Anbu", "Thara", "Chandran", "Ilam", "Mathi",
	"Oviya", "Pandi", "Rathi", "Senthil", "Uma", "Vimal", "Yazhini", "Ezhil",
]

## Overlords for the N, E, S, W exits, in that order.
@export var exit_overlords: Array[OverlordData] = []
## Hand-made villagers; spawned before any placeholder ones.
@export var villagers: Array[VillagerData] = []
## Training stations and the cell each one stands on (same order).
@export var stations: Array[StationData] = []
@export var station_cells: Array[Vector2i] = [
	Vector2i(18, 25), Vector2i(32, 25), Vector2i(25, 18), Vector2i(25, 32), Vector2i(15, 30),
]
@export var layout_seed: int = 7
@export var building_count: int = 30
@export var villager_count: int = 40
@export var plaza_radius_tiles: int = 3

@onready var _ground: TileMapLayer = $Ground
@onready var _world: Node2D = $World
@onready var _player: Node2D = $World/Player


func _ready() -> void:
	var layout := VillageLayout.new()
	layout.begin(_ground.map_size, layout_seed, plaza_radius_tiles)
	for i in mini(stations.size(), station_cells.size()):
		layout.reserve_area(station_cells[i], STATION_SIZE)
	layout.place_buildings(building_count)
	layout.place_villagers(villager_count)

	_player.global_position = _ground.get_center_world()
	_spawn_stations()
	_spawn_buildings(layout)
	_spawn_villagers(layout)
	_spawn_exits()


func _spawn_stations() -> void:
	for i in mini(stations.size(), station_cells.size()):
		var station := STATION_SCENE.instantiate() as Node2D
		station.set("data", stations[i])
		station.set("size_in_tiles", Vector2(STATION_SIZE))
		station.global_position = _ground.cell_to_world(station_cells[i])
		_world.add_child(station)


func _spawn_buildings(layout: VillageLayout) -> void:
	for i in layout.building_cells.size():
		var building := BUILDING_SCENE.instantiate() as StaticBody2D
		building.set("size_in_tiles", Vector2(layout.building_sizes[i]))
		building.global_position = _ground.cell_to_world(layout.building_cells[i])
		_world.add_child(building)


func _spawn_villagers(layout: VillageLayout) -> void:
	for i in layout.villager_cells.size():
		var villager := VILLAGER_SCENE.instantiate() as CharacterBody2D
		villager.set("data", _villager_data_for(i))
		villager.global_position = _ground.cell_to_world(layout.villager_cells[i])
		_world.add_child(villager)


func _villager_data_for(index: int) -> VillagerData:
	if index < villagers.size():
		return villagers[index]
	var data := VillagerData.new()
	var extra: int = index - villagers.size()
	data.id = StringName("villager_%d" % extra)
	data.villager_name = PLACEHOLDER_NAMES[extra % PLACEHOLDER_NAMES.size()]

	if not exit_overlords.is_empty():
		data.overlord = exit_overlords[extra % exit_overlords.size()]
	return data


func _spawn_exits() -> void:
	var last: int = _ground.map_size - 1
	var exit_cells: Array[Vector2i] = [
		Vector2i(0, 0), Vector2i(last, 0), Vector2i(last, last), Vector2i(0, last),
	]
	for i in mini(exit_overlords.size(), exit_cells.size()):
		var exit := CAVE_EXIT_SCENE.instantiate() as Area2D
		exit.set("overlord", exit_overlords[i])
		exit.global_position = _ground.cell_to_world(exit_cells[i])
		_world.add_child(exit)
