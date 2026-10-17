class_name MessagePopup
extends CanvasLayer
## Generic message popup with one OK button. `show_message()` pauses until dismissed:
##   await popup.show_message("A year at the Healer's Hut…")

signal _dismissed()

@onready var _message: Label = %Message
@onready var _ok_button: Button = %OkButton


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ok_button.pressed.connect(func() -> void: _dismissed.emit())


func show_message(text: String) -> void:
	if visible:
		return
	_message.text = text
	visible = true
	get_tree().paused = true
	_ok_button.grab_focus()
	await _dismissed
	visible = false
	get_tree().paused = false
