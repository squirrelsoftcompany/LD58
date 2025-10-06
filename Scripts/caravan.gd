extends Node3D
class_name Caravan

var current_zone : Place
var next_zone : Place
var movement_tween : Tween
var gold : int = 0
var guards : Array[Guard]
var ambushed : bool = false
var current_path : Road

@export var capital : Place
@export var food : int = 10
@export var max_food : int = 10
@export var guard_scene: PackedScene

func _ready():
	current_zone = capital
	position = capital.position
	GlobalEventHolder.turnEnd.connect(_move)
	GlobalEventHolder.loopStart.emit() ## TODO game bootup sequence
	GlobalEventHolder.connect("reward_received", Callable(self, "_on_reward_received"))
	GlobalEventHolder.connect("endAmbush", Callable(self, "_on_endAmbush"))
	print("TODO: caravan still starts the loop")
	#Add the first guard
	var guard = guard_scene.instantiate()
	guards.append(guard)
	

func _move(x:Place):
	next_zone = x
	_find_path()
	food -= current_path.cost
	look_at(next_zone.position)
	
	var bandits_on_path = generateAmbush(current_zone,next_zone)
	var next_pos
	var start = global_position
	var end = next_zone.global_position
	
	movement_tween = create_tween()
	if bandits_on_path > 0:
		next_pos = start.lerp(end, 0.5)
		movement_tween.tween_property(self,"position",next_pos,0.5)
		movement_tween.tween_callback(Callable(self, "_half_move_done").bind(bandits_on_path))
	else:
		next_pos = next_zone.position
		movement_tween.tween_property(self,"position",next_pos,0.5)
		movement_tween.tween_callback(_move_done)
		

func _find_path():
	var i : int = 0
	while current_zone.outgoing_roads[i].to != next_zone and i < current_zone.outgoing_roads.size():
		i+=1
	current_path = current_zone.outgoing_roads[i]

func _move_done():
	current_zone = next_zone
	gold += current_zone.taxable
	print("TODO: show gold collected, it's ",gold," btw")
	if current_zone == capital :
		GlobalEventHolder.loopEnd.emit()
		print("TODO: capital market")
		gold = 0
		GlobalEventHolder.loopStart.emit()
		food = max_food
	GlobalEventHolder.turnStart.emit(current_zone)
	current_path = null

func _half_move_done(bandits_on_path : int):
	if bandits_on_path > 0:
		var ambush_instance : Ambush = load("res://scene/ambush.tscn").instantiate()
		if ambush_instance:
			add_child(ambush_instance)
			GlobalEventHolder.emit_signal("startAmbush", bandits_on_path)

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
			"guard":
				if amount > 0:
					for i in amount:
						var guard = guard_scene.instantiate()
						guards.append(guard)
				elif amount < 0 and guards.size() > 1:
					var random_index = randi_range(1, guards.size() - 1)
					var guard_to_remove = guards[random_index]
					guards.remove_at(guard_to_remove)
					guard_to_remove.free()
			"p_crimerate":
				current_zone.crimeRate += amount
				current_zone.crimeRate = max(current_zone.crimeRate, 0)
			"p_population":
				current_zone.crimeRate += amount
				current_zone.crimeRate = max(current_zone.crimeRate, 0)
			"p_food":
				current_zone.food += amount
				current_zone.food = max(current_zone.crimeRate, 0)
			_:
				push_warning("Unknown reward type: %s" % resource_name)

func _on_endAmbush():
	#Go to next pos
	movement_tween = create_tween()
	movement_tween.tween_property(self,"position",next_zone.global_position,0.5)
	movement_tween.tween_callback(_move_done)
	ambushed = false

func get_guards() -> Array[Guard]:
	return guards
	
func generateAmbush(p_current_zone: Place,p_next_zone: Place) -> int:
	var current_crimerate
	var next_crimerate
	if not p_current_zone:
		current_crimerate = 0
	else:
		current_crimerate = p_current_zone.crimeRate
	if not p_next_zone:
		next_crimerate = 0
	else:
		next_crimerate = p_next_zone.crimeRate
		
	var path_crimerate = (current_crimerate + next_crimerate)/2
	print("path crimerate : ",path_crimerate)
	var nb_bandit
	if path_crimerate < 15:
		nb_bandit = 0
	else:
		path_crimerate = max(path_crimerate - (randi() % 16),0)
		var mapped = (path_crimerate - 20) / (100 - 20) * 7 + 1
		nb_bandit = int(clamp(round(mapped), 1, 8))
	return nb_bandit
