extends Node3D

var event: EventData = load("res://DataEvents/event_coolGuy.tres")

@onready var ui = $EventUI

func _ready() -> void:
	var place_stats = {
		"gold": 40,
		"food": 20,
		"crimerate": 5,
		"population": 15
	}

	var place_type = "village"
	GlobalEventHolder.emit_signal("request_event", place_stats, place_type)
