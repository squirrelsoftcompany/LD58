extends Node3D

var current_zone : Place
var next_zone : Place
var movement_tween : Tween
var gold : int = 0

@export var capital : Node3D
@export var food : int = 10

func _ready():
	position = capital.position
	GlobalEventHolder.turnEnd.connect(_move)
	GlobalEventHolder.loopStart.emit() ## TODO game bootup sequence
	print("TODO: caravan still starts the loop")

func _move(x:Place):
	next_zone = x
	look_at(next_zone.position)
	movement_tween = create_tween()
	movement_tween.tween_property(self,"position",next_zone.position,0.5)
	movement_tween.tween_callback(_move_done)

func _move_done():
	current_zone = next_zone
	gold += current_zone.taxable
	print("TODO: show gold collected, it's ",gold," btw")
	if current_zone == capital :
		GlobalEventHolder.loopEnd.emit()
	else:
		GlobalEventHolder.turnStart.emit(current_zone)
