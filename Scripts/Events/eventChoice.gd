extends Resource
class_name EventChoice

@export var text: String                   # text shown on the button
@export var rewards := {
	"gold": 0,
	"food": 0,
	"guard": 0,
	"p_crimerate": 0,
	"p_population": 0,
	"p_food": 0,
	"hide_gold": 0,
	"hide_food": 0,
	"hide_guard": 0,
	"hide_p_crimerate": 0,
	"hide_p_population": 0,
	"hide_p_food": 0,
	"hide_p_gold": 0,
}     # {"gold": -5, "food": 2}
@export var followup_dialogue: Array[String] = []  
