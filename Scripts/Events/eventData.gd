extends Resource
class_name EventData

@export var title: String
@export var dialogue: Array[String]   # lines of dialogue
@export var choices: Array[EventChoice]  # each choice with its own rewards

#Trigger condition
@export var type: String = "" # "inn", "camp", "village"
@export var min_gold: int = 0
@export var max_gold: int = 100
@export var min_food: int = 0
@export var max_food: int = 100
@export var min_crime: int = 0
@export var max_crime: int = 100
@export var min_population: int = 0
@export var max_population: int = 100
@export var capital: bool = false
