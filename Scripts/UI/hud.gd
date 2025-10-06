extends Control

@export var food_label : Label
@export var food_max_label : Label
@export var gold_label : Label
@export var gold_goal_label : Label

var caravan : Caravan

func _ready():
	caravan = get_tree().get_first_node_in_group("caravan")
	GlobalEventHolder.turnStart.connect(func(_x): _update_gold())
	GlobalEventHolder.turnEnd.connect(func(_x): _update_food())
	GlobalEventHolder.reward_received.connect(func(_x): _update_all())
	GlobalEventHolder.loopStart.connect(func(_x): _update_all())
	GlobalEventHolder.loopEnd.connect(func(_x): _update_all())
	_update_all()
	food_max_label.text = str(caravan.max_food)

func _update_all():
	_update_food()
	_update_gold()
	food_max_label.text = str(caravan.max_food)
	

func _update_gold():
	gold_label.text = str(caravan.gold)

func _update_food():
	food_label.text = str(caravan.food)
