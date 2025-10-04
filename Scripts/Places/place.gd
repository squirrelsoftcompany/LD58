extends Node
class_name Place

enum Taxes { LOW, MEDIUM, HIGH }

@export_group("Stats")
@export var goldStock: int = 0
@export var foodStock: int = 0
@export var population: int = 0
@export var crimeRate: float = 0
@export var taxeLevel: Taxes = Taxes.LOW

@export_group("Generation")
@export var minGold: int = 0
@export var maxGold: int = 0
@export var minFood: int = 0
@export var maxFood: int = 0
@export var minPopulation: int = 0
@export var maxPopulation: int = 0
@export var minCrimeRate: int = 0
@export var maxCrimeRate: int = 0


func generatePlace() -> void:
	goldStock = randi_range(minGold, maxGold) 
	foodStock = randi_range(minFood, maxFood)
	population = randi_range(minPopulation, maxPopulation) 
	crimeRate = randi_range(minCrimeRate, maxCrimeRate)

func _ready():
	GlobalEventHolder.connect("loopEnd", func(): _updatePlace())
	
func _updatePlace():
	pass
	
