class_name ConfirmPopup
extends CanvasLayer
## Generic Yes/No popup. `ask()` shows the question, pauses the game, and returns the answer:
##   var yes: bool = await popup.ask("Leave?")

signal _answered(yes: bool)

@onready var _question: Label = %Question
@onready var _yes_button: Button = %YesButton
@onready var _no_button: Button = %NoButton


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_yes_button.pressed.connect(func() -> void: _answered.emit(true))
	_no_button.pressed.connect(func() -> void: _answered.emit(false))


func ask(question: String) -> bool:
	if visible:
		return false
	_question.text = question
	visible = true
	get_tree().paused = true
	_no_button.grab_focus()
	var yes: bool = await _answered
	visible = false
	get_tree().paused = false
	return yes
