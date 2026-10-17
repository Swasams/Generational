class_name CavePlaceholder
extends Control
## Placeholder cave scene: names the overlord's territory and offers a way back.
## Set `overlord` before adding to the tree (CaveTravel does this).

const VILLAGE_SCENE_PATH: String = "res://scenes/village/village.tscn"
const TINT_AMOUNT: float = 0.35

var overlord: OverlordData

@onready var _background: ColorRect = %Background
@onready var _title: Label = %Title
@onready var _back_button: Button = %BackButton


func _ready() -> void:
	var overlord_name: String = "an unknown overlord"
	var tint: Color = Palette.CAVE_MOUTH

	if overlord != null:
		overlord_name = overlord.display_name
		tint = Palette.CAVE_MOUTH.lerp(overlord.color, TINT_AMOUNT)
	_title.text = "Entering %s's territory" % overlord_name
	_background.color = tint
	_back_button.pressed.connect(_on_back_pressed)
	_back_button.grab_focus()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(VILLAGE_SCENE_PATH)
