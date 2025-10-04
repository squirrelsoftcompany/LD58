@tool
extends Node3D
class_name Road

@export var text_altitude : float = 5
@export var cobbled : bool = false
@export var cost : int = 1
@export var crimerate : float = 0 ## percentage

@export var from : Node3D :
	set(x):
		from = x
		var curve = Curve3D.new()
		curve.add_point(from.position)
		curve.add_point($Path3D.curve.get_point_position(1))
		$Path3D.curve = curve

@export var to : Node3D :
	set(x):
		to = x
		var curve = Curve3D.new()
		curve.add_point($Path3D.curve.get_point_position(0))
		curve.add_point(to.position)
		$Path3D.curve = curve

func _ready():
	innit()
	if not Engine.is_editor_hint():
		from.outgoing_roads.append(self)
		GlobalEventHolder.turnEnd.connect(func(_x):hide_cost())

func _process(_delta):
	if Engine.is_editor_hint() and from != null and to != null:
		innit()

func innit():
	var path = $Path3D
	path.curve.set_point_position(0,from.position)
	path.curve.set_point_position(1,to.position)
	$Sprite3D.position = ((to.position-from.position)/2)+from.position
	$Sprite3D.position.y = text_altitude
	$Sprite3D/SubViewport/Label.text = str(cost)

func show_cost():
	$Sprite3D.show()

func hide_cost():
	$Sprite3D.hide()
