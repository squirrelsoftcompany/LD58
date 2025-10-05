extends Resource
class_name EventChoice

@export var text: String                   # text shown on the button
@export var rewards: Dictionary = {}       # {"gold": -5, "food": 2}
@export var followup_dialogue: Array[String] = []  
