@tool
extends Node3D

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

func _process(_delta):
	if Engine.is_editor_hint():
		innit()

func innit():
	var path = $Path3D
	path.curve.set_point_position(0,from.position)
	path.curve.set_point_position(1,to.position)
