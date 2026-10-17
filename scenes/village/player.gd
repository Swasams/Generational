extends CharacterBody2D
## The current daughter. Moves with WASD/arrows, or walks to a tapped point
## (arrives via Events.ground_clicked). Keyboard input cancels a tap target.

const ARRIVE_DISTANCE: float = 4.0
const STUCK_SPEED: float = 5.0
const ISO_Y_SCALE: float = 0.5

@export var speed: float = 230.0

var _target: Vector2 = Vector2.ZERO
var _has_target: bool = false


func _ready() -> void:
	Events.ground_clicked.connect(_on_ground_clicked)
	Events.cave_travel_declined.connect(_clear_target)


func _physics_process(_delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if input != Vector2.ZERO:
		_has_target = false
		velocity = Vector2(input.x, input.y * ISO_Y_SCALE) * speed
	elif _has_target:
		var to_target := _target - global_position

		if to_target.length() <= ARRIVE_DISTANCE:
			_clear_target()
			velocity = Vector2.ZERO
		else:
			velocity = to_target.normalized() * speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()

	if _has_target and get_real_velocity().length() < STUCK_SPEED:
		_clear_target()


func _on_ground_clicked(world_position: Vector2) -> void:
	_target = world_position
	_has_target = true


func _clear_target() -> void:
	_has_target = false
