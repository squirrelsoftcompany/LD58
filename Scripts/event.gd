extends CanvasLayer

@onready var text_box: Panel = $TextBoxPanel
@onready var text_label: RichTextLabel = $TextBoxPanel/MarginContainer/RichTextLabel
@onready var choice_popup: PanelContainer = $ChoicePopup
@onready var popup_label: RichTextLabel = $ChoicePopup/MarginContainer/VBoxContainer/PopupLabel
@onready var button_container: HBoxContainer = $ChoicePopup/MarginContainer/VBoxContainer/HBoxContainer

var dialogue_queue: Array[String] = []
var current_index: int = 0
var choice_callback: Callable	 # callback when a choice is selected
var choice_event: Array = []	 # list of EventChoice objects for the current event

# ---------------------------------------------------
# Global UI visibility management
# ---------------------------------------------------
func display_ui(display: bool) -> void:
	visible = display
	if not display:
		_clear_all()

func _clear_all() -> void:
	text_label.clear()
	choice_popup.visible = false
	dialogue_queue.clear()
	current_index = 0
	choice_event.clear()

# ---------------------------------------------------
# Main text box
# ---------------------------------------------------
func show_text_array(lines: Array[String], choices: Array, callback: Callable) -> void:
	dialogue_queue = lines.duplicate()
	current_index = 0
	choice_event = choices.duplicate()
	choice_callback = callback
	_display_current_line()

func _display_current_line() -> void:
	if current_index >= 0 and current_index < dialogue_queue.size():
		text_label.clear()
		text_label.append_text(dialogue_queue[current_index])


# ---------------------------------------------------
# Display choices popup
# ---------------------------------------------------
func _show_choices() -> void:
	popup_label.text = "Make a choice:"

	# Clear old buttons
	for child in button_container.get_children():
		child.queue_free()

	# Create new buttons
	for choice_obj in choice_event:
		var btn = Button.new()
		btn.text = choice_obj.text
		btn.pressed.connect(func():
			choice_popup.visible = false
			if choice_callback != null:
				choice_callback.call(choice_obj)
		)
		button_container.add_child(btn)
		
	var container = choice_popup.get_child(0)  # MarginContainer
	choice_popup.custom_minimum_size = container.get_combined_minimum_size() + Vector2(20, 20)
	choice_popup.visible = true

# ---------------------------------------------------
# Input handling (SPACE or ENTER to continue text)
# ---------------------------------------------------
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):  # SPACE or ENTER
		if current_index + 1 < dialogue_queue.size():
			current_index += 1
			_display_current_line()
		else:
			if choice_event.size() > 0:
				_show_choices()
			else:
				text_label.clear()
				dialogue_queue.clear()
				current_index = 0
