extends CanvasLayer
## Talk / Gift / Close menu that floats next to the clicked villager.
## Opens on Events.villager_clicked, closes on Close or a ground click.

const OFFSET := Vector2(28.0, -150.0)
const MARGIN: float = 8.0

@onready var _panel: PanelContainer = %Panel
@onready var _name_label: Label = %Name
@onready var _overlord_label: Label = %Overlord
@onready var _bond_label: Label = %Bond
@onready var _dots: Control = %Dots
@onready var _message: Label = %Message
@onready var _talk_button: Button = %TalkButton
@onready var _gift_button: Button = %GiftButton
@onready var _close_button: Button = %CloseButton

var _villager: Node2D
var _data: VillagerData


func _ready() -> void:
	visible = false
	_dots.set("color", Palette.CHARISMA)
	_bond_label.add_theme_color_override("font_color", Palette.CHARISMA)
	Events.villager_clicked.connect(open)
	Events.ground_clicked.connect(func(_position: Vector2) -> void: close())
	_talk_button.pressed.connect(_on_talk)
	_gift_button.pressed.connect(_on_gift)
	_close_button.pressed.connect(close)
	PlayerState.trinkets_changed.connect(func(_count: int) -> void: _refresh_gift_button())


func open(villager: Node2D) -> void:
	if villager == null or villager.get("data") == null:
		return
	_villager = villager
	_data = villager.get("data")
	_name_label.text = _data.villager_name
	_overlord_label.text = "Follower of %s" % (_data.overlord.display_name if _data.overlord else "nobody")
	_name_label.add_theme_color_override("font_color", _data.overlord.color if _data.overlord else Palette.TEXT)
	_message.text = ""
	_refresh_bond()
	_refresh_gift_button()
	visible = true
	Events.villager_menu_opened.emit(villager)


func close() -> void:
	if not visible:
		return
	visible = false
	_villager = null
	Events.villager_menu_closed.emit()


func _process(_delta: float) -> void:
	if not visible or not is_instance_valid(_villager):
		return
	var screen_position: Vector2 = _villager.get_global_transform_with_canvas().origin + OFFSET
	var viewport_size: Vector2 = _panel.get_viewport_rect().size
	screen_position.x = clampf(screen_position.x, MARGIN, viewport_size.x - _panel.size.x - MARGIN)
	screen_position.y = clampf(screen_position.y, MARGIN, viewport_size.y - _panel.size.y - MARGIN)
	_panel.position = screen_position


func _on_talk() -> void:
	_message.text = VillagerInteraction.talk(_data)
	_refresh_bond()


func _on_gift() -> void:
	_message.text = VillagerInteraction.gift(_data)
	_refresh_bond()


func _refresh_bond() -> void:
	var relationship: RelationshipData = Relationships.get_relationship(_data.id)
	var points: int = relationship.bond_points() if relationship else 0
	_bond_label.text = "Bond %d" % points
	_dots.set("total", RelationshipData.TALKS_PER_POINT)
	_dots.set("filled", relationship.talk_progress() if relationship else 0)


func _refresh_gift_button() -> void:
	var can_gift: bool = VillagerInteraction.can_gift()
	_gift_button.disabled = not can_gift
	_gift_button.text = "Gift (%d)" % PlayerState.trinkets

	if not can_gift and _message.text.is_empty():
		_message.text = VillagerInteraction.NO_TRINKETS
