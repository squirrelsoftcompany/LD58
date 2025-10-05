extends Node
class_name Place

enum Taxes { LOW, MEDIUM, HIGH }
@export_group("WorldMap")
@export var capital : bool = false

@export_group("Stats")
@export var goldStock: int = 0
@export var foodStock: int = 0
@export var population: int = 0
@export var crimeRate: float = 0
@export var taxeLevel: int = Taxes.LOW :
	set(x):
		while x > Taxes.HIGH:
			x -= 3
		taxeLevel = x

@export_group("Generation")
@export var minGold: int = 0
@export var maxGold: int = 0
@export var minFood: int = 0
@export var maxFood: int = 0
@export var minPopulation: int = 0
@export var maxPopulation: int = 0
@export var minCrimeRate: int = 0
@export var maxCrimeRate: int = 0

var outgoing_roads : Array[Road]
var hovered : bool = false
var accessible : bool = false
var current : bool = false
var tax_hovered : bool = false
var taxable : int

@onready var tax_Vis : Control = $Sprite3D/SubViewport/HBoxContainer/Taxes

func generatePlace() -> void:
	goldStock = randi_range(minGold, maxGold) 
	foodStock = randi_range(minFood, maxFood)
	population = randi_range(minPopulation, maxPopulation) 
	crimeRate = randi_range(minCrimeRate, maxCrimeRate)

func _ready():
	GlobalEventHolder.connect("loopEnd", func(): _updatePlace())
	GlobalEventHolder.turnStart.connect(func(x): if x == self: _collector_visit())
	GlobalEventHolder.turnEnd.connect(func(_x): _turn_end())
	GlobalEventHolder.loopStart.connect(_on_loop_start)

func _on_loop_start():
	$Sprite3D/SubViewport/HBoxContainer.visible= goldStock >= 3
	$Sprite3D/StaticBody3D.show()
	tax_Vis.show()
	_on_tax_changed()
	_hover()
	if capital:
		_collector_visit()

func _updatePlace():
	print("TODO: _updatePlace() in place")


func _hover(x : bool = false):
	if accessible:
		hovered = x
		var tween : Tween = create_tween()
		if hovered and accessible:
			tween.tween_property($CentralPuck,"position:y",0.5,0.2)
		else:
			tween.tween_property($CentralPuck,"position:y",0,0.2)

func _input(event):
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if hovered:
				GlobalEventHolder.turnEnd.emit(self)
			elif tax_hovered:
				_on_tax_changed(1)

func _collector_visit() :
	accessible = false
	current = true
	for road in outgoing_roads:
		road.to.accessible = true
		road.show_cost()
	goldStock -= taxable
	tax_Vis.hide()
	$Sprite3D/StaticBody3D.hide()


func _turn_end():
	current = false
	accessible = false
	hovered = false

func tax_hover(x:bool=false):
	tax_hovered = x
	tax_Vis.get_child(1).visible = x

func _on_tax_changed(x : int = 0):
	taxeLevel += x
	tax_Vis.get_node("VBoxContainer/TaxLevel2").visible = taxeLevel >= Taxes.MEDIUM
	tax_Vis.get_node("VBoxContainer/TaxLevel").visible = taxeLevel == Taxes.HIGH
	@warning_ignore("integer_division")
	taxable = goldStock*(taxeLevel+1)/3
	$Sprite3D/SubViewport/HBoxContainer/Label.text = str(taxable)
