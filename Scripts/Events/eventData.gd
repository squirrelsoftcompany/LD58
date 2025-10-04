extends Resource
class_name EventData

@export var title: String
@export var dialogue: Array[String]   # lines of dialogue
@export var choices: Array[EventChoice]  # each choice with its own rewards
