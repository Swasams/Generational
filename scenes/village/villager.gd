extends CharacterBody2D
## A villager colored by their overlord. Wanders slowly around their home spot, stands
## still while their Talk/Gift menu is open, and speaks a bubble on Events.villager_spoke.

const ARRIVE_DISTANCE: float = 3.0
const STUCK_SPEED: float = 2.0

@export var data: VillagerData
@export var speed: float = 35.0
@export var wander_radius: float = 90.0
@export var idle_seconds: Vector2 = Vector2(1.5, 4.0)

@onready var _visual: Node2D = $CapsuleVisual
@onready var _bubble: Node2D = $SpeechBubble

var _home: Vector2 = Vector2.ZERO
var _target: Vector2 = Vector2.ZERO
var _idle_left: float = 0.0
var _frozen: bool = false
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	_home = global_position
	_target = _home
	_idle_left = _rng.randf_range(0.2, idle_seconds.y)

	if data != null and data.overlord != null:
		_visual.body_color = data.overlord.color
	Events.villager_spoke.connect(_on_villager_spoke)
	Events.villager_menu_opened.connect(_on_menu_opened)
	Events.villager_menu_closed.connect(func() -> void: _frozen = false)
	Clock.year_advanced.connect(_on_year_advanced)


func _physics_process(delta: float) -> void:
	if _frozen:
		velocity = Vector2.ZERO
		return

	if _idle_left > 0.0:
		_idle_left -= delta
		velocity = Vector2.ZERO

		if _idle_left <= 0.0:
			_pick_target()
	else:
		var to_target := _target - global_position

		if to_target.length() <= ARRIVE_DISTANCE:
			_start_idle()
		else:
			velocity = to_target.normalized() * speed
	move_and_slide()

	if velocity != Vector2.ZERO and get_real_velocity().length() < STUCK_SPEED:
		_start_idle()


func _pick_target() -> void:
	var angle: float = _rng.randf() * TAU
	var distance: float = _rng.randf_range(wander_radius * 0.3, wander_radius)
	# Squash y so the wander area reads as an isometric ellipse.
	_target = _home + Vector2(cos(angle), sin(angle) * 0.5) * distance


func _start_idle() -> void:
	velocity = Vector2.ZERO
	_idle_left = _rng.randf_range(idle_seconds.x, idle_seconds.y)


func _on_villager_spoke(villager_id: StringName, line: String) -> void:
	if data != null and data.id == villager_id:
		_bubble.show_text(line)


func _on_menu_opened(villager: Node2D) -> void:
	_frozen = villager == self

	if _frozen:
		_start_idle()


func _on_year_advanced(_world_year: int, _age: int) -> void:
	if data != null:
		data.talked_this_year = false
