extends Node3D
class_name Caravan

var current_zone : Place
var next_zone : Place
var movement_tween : Tween
var gold : int = 0
var guard : Array[Guard]

@export var capital : Node3D
@export var food : int = 10

func _ready():
	position = capital.position
	GlobalEventHolder.turnEnd.connect(_move)
	GlobalEventHolder.loopStart.emit() ## TODO game bootup sequence
	GlobalEventHolder.connect("reward_received", Callable(self, "_on_reward_received"))
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
		print("TODO: capital market")
		gold = 0
		GlobalEventHolder.loopStart.emit()
	GlobalEventHolder.turnStart.emit(current_zone)
	
func _on_reward_received(rewards: Dictionary) -> void:
	for resource_name in rewards.keys():
		var amount = rewards[resource_name]

		match resource_name.to_lower():
			"gold":
				gold += amount
				gold = max(gold, 0)
				print("Gold new quantity : ",gold)
			"food":
				food += amount
				food = max(food, 0)
				print("Food new quantity : ",food)
			_:
				push_warning("Unknown reward type: %s" % resource_name)

func get_guards() -> Array[Guard]:
	return guard
