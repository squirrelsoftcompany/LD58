extends Node3D

var event: EventData = load("res://DataEvents/event_coolGuy.tres")

@onready var ui = $EventUI

func _ready() -> void:
	# show the UI
	ui.display_ui(true)

	ui.show_text_array(
		event.dialogue,
		event.choices,
		func(selected_choice):
			print("Player chose:", selected_choice.text)
	)
