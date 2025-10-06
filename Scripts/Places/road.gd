@tool
extends Node3D
class_name Road

@export var text_altitude : float = 5
@export var cobbled : bool = false
@export var cost : int = 1:
	set(x):
		if x <1:
			x=1
		cost = x
		$Path3D/CSGPolygon3D.set_instance_shader_parameter("cost",cost-1)

@export var crimeRate : float = 0 ## percentage

@export var from : Node3D :
	set(x):
		from = x
		var curve = Curve3D.new()
		curve.add_point(from.position)
		curve.add_point($Path3D.curve.get_point_position(1))
		$Path3D.curve = curve
		change = true

@export var to : Node3D :
	set(x):
		to = x
		var curve = Curve3D.new()
		curve.add_point($Path3D.curve.get_point_position(0))
		curve.add_point(to.position)
		$Path3D.curve = curve
		change = true

var change : bool = true

func _ready():
	cost = cost
	$Sprite3D.texture.viewport_path = $Sprite3D/SubViewport.get_path()
	if not Engine.is_editor_hint():
		from.outgoing_roads.append(self)
		GlobalEventHolder.turnEnd.connect(func(_x):hide_cost())
		GlobalEventHolder.loopStart.connect(_update_loop)

func _process(_delta):
	position = position
	if change:
		change = false
		innit()

func innit():
	var path = $Path3D
	path.curve.set_point_position(0,from.position)
	path.curve.set_point_position(1,to.position)
	$Sprite3D.position = ((to.position-from.position)/2)+from.position
	$Sprite3D.position.y = text_altitude
	$Sprite3D/SubViewport/Label.text = str(cost)
	if Engine.is_editor_hint() and from != null and to != null:
		$Path3D/StaticBody3D/CollisionShape3D.shape = $Path3D/CSGPolygon3D.bake_collision_shape()

func show_cost():
	$Sprite3D.show()

func hide_cost():
	$Sprite3D.hide()

func _update_loop():
	crimeRate = (from.crimeRate + to.crimeRate)/2
