extends CanvasLayer

@onready var text_box: Panel = $TextBoxPanel
@onready var text_label: RichTextLabel = $TextBoxPanel/MarginContainer/RichTextLabel
@onready var choice_popup: PanelContainer = $ChoicePopup
@onready var popup_label: RichTextLabel = $ChoicePopup/MarginContainer/VBoxContainer/PopupLabel
@onready var choices_container: VBoxContainer = $ChoicePopup/MarginContainer/VBoxContainer/ChoicesContainer

var dialogue_queue: Array[String] = []
var current_index: int = 0
var choice_callback: Callable	 # callback when a choice is selected
var choice_event: Array = []	 # list of EventChoice objects for the current event

enum UIState { IDLE, DIALOGUE, CHOICES, FOLLOWUP }
var ui_state: UIState = UIState.IDLE


func _ready():
	GlobalEventHolder.connect("event_triggered", Callable(self, "_on_event_triggered"))

func _on_event_triggered(event_data: EventData) -> void:
	show_text_array(
		event_data.dialogue,
		event_data.choices,
	func(selected_choice):
			print("Player chose:", selected_choice.text))
	display_ui(true)

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
	visible = false

# ---------------------------------------------------
# Main text box
# ---------------------------------------------------
func show_text_array(lines: Array[String], choices: Array, callback: Callable) -> void:
	dialogue_queue = lines.duplicate()
	current_index = 0
	choice_event = choices.duplicate()
	choice_callback = callback
	ui_state = UIState.DIALOGUE
	_display_current_line()

func _display_current_line() -> void:
	if current_index >= 0 and current_index < dialogue_queue.size():
		text_label.clear()
		text_label.append_text(dialogue_queue[current_index])


# ---------------------------------------------------
# Display choices popup
# ---------------------------------------------------
func _show_choices(choices: Array) -> void:
	popup_label.text = "Make a choice:"

	# Clear old buttons
	for child in choices_container.get_children():
		child.queue_free()
		
	for choice_data in choices:
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 16) 
		
		var button = Button.new()
		button.text = choice_data["text"]
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.connect("pressed", Callable(self, "_on_choice_pressed").bind(choice_data))
		hbox.add_child(button)
		
		var rewards_container = HBoxContainer.new()
		button.size_flags_horizontal = Control.SIZE_FILL
		
		for resource_name in choice_data["rewards"].keys():
			var amount = choice_data["rewards"][resource_name]
			
			var reward_label = Label.new()
			reward_label.text = "%s %+d" % [resource_name, amount]
			rewards_container.add_child(reward_label)
			
			# Variante : use icon
			# var icon = TextureRect.new()
			# icon.texture = load("res://icons/%s.png" % resource_name)
			# rewards_container.add_child(icon)
			# and add label for quantity
		hbox.add_child(rewards_container)
		
		choices_container.add_child(hbox)
	equalize_button_widths(choices_container)
	choice_popup.visible = true

# ---------------------------------------------------
# Input handling (SPACE or ENTER to continue text)
# ---------------------------------------------------
func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_accept"):
		return
	
	if ui_state == UIState.DIALOGUE or ui_state == UIState.FOLLOWUP:
		if current_index + 1 < dialogue_queue.size():
			current_index += 1
			_display_current_line()
		else:
			if ui_state == UIState.DIALOGUE and choice_event.size() > 0:
				ui_state = UIState.CHOICES
				_show_choices(choice_event)
			else:
				_clear_all()
				ui_state = UIState.IDLE

func equalize_button_widths(container: VBoxContainer) -> void:
	var max_width = 0
	for hbox in container.get_children():
		if hbox.get_child_count() > 0 and hbox.get_child(0) is Button:
			var button: Button = hbox.get_child(0)
			max_width = max(max_width, button.get_combined_minimum_size().x)
	
	for hbox in container.get_children():
		if hbox.get_child_count() > 0 and hbox.get_child(0) is Button:
			var button: Button = hbox.get_child(0)
			button.custom_minimum_size.x = max_width

func _on_choice_pressed(choice: EventChoice) -> void:
	choice_popup.visible = false
	choice_event.clear()

	# Apply rewards
	for resource_name in choice.rewards.keys():
		var amount = choice.rewards[resource_name]
		print("Reward:", resource_name, amount)
		GlobalEventHolder.emit_signal("reward_received", choice.rewards)
		

	# Show follow-up dialogue if exists
	if choice.followup_dialogue.size() > 0:
		dialogue_queue = choice.followup_dialogue.duplicate()
		current_index = 0
		ui_state = UIState.FOLLOWUP
		_display_current_line()
	else:
		_clear_all()
		ui_state = UIState.IDLE

	# External callback if needed
	if choice_callback.is_valid():
		choice_callback.call(choice)
