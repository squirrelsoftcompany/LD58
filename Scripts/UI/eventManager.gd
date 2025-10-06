extends Node
class_name EventManager

@export var all_events: Array[EventData] = []

var caravan: Caravan

func _ready():
	randomize()
	GlobalEventHolder.connect("request_event", Callable(self, "_on_request_event"))
	GlobalEventHolder.connect("turnStart", Callable(self, "_on_turn_start"))
	for node in get_tree().get_nodes_in_group("caravan"):
		caravan = node
	var dir_path = "res://DataEvents/"
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var filename = dir.get_next()
		while filename != "":
			if filename.ends_with(".tres"):
				var ev = load(dir_path + filename) as EventData
				if ev:
					all_events.append(ev)
			filename = dir.get_next()
		dir.list_dir_end()


#func _on_request_event(place_stats: Dictionary, place_type: String) -> void:
	#var event = trigger_random_event(place_stats, place_type)
	#if event:
		#GlobalEventHolder.emit_signal("event_triggered", event)
		
func _on_turn_start(place : Place) -> void:
	if randf() < 0.6 or place.capital: #60%
		var place_type
		if place.capital:
			place_type = "capital"
		else:
			place_type = place.get_place_type()
		var event = trigger_random_event(place.get_stats_dict(),place_type)
		if event:
			GlobalEventHolder.emit_signal("event_triggered", event)

func get_available_events(place_stats: Dictionary, place_type: String) -> Array:
	var available := []
	for event in all_events:
		if not event.type.is_empty() and event.type != place_type:
			continue
		if place_stats["gold"] < event.min_gold or place_stats["gold"] > event.max_gold:
			continue
		if place_stats["food"] < event.min_food or place_stats["food"] > event.max_food:
			continue
		if place_stats["crimerate"] < event.min_crime or place_stats["crimerate"] > event.max_crime:
			continue
		if place_stats["population"] < event.min_population or place_stats["population"] > event.max_population:
			continue
		if caravan.gold < event.personal_gold_min:
			continue
		if caravan.food < event.personal_food_min:
			continue
		if caravan.food > event.personal_food_max:
			continue
		if place_type == "capital" and !event.capital:
			continue
		if place_type != "capital" and event.capital:
			continue
		if event.objectif and caravan.gold < caravan.gold_goal:
			continue
		if !event.objectif and caravan.gold >= caravan.gold_goal:
			continue
		available.append(event)
	return available

func trigger_random_event(place_stats: Dictionary, place_type: String) -> EventData:
	var candidates = get_available_events(place_stats, place_type)
	if candidates.size() == 0:
		return null
	var index = randi() % candidates.size()
	return candidates[index]
