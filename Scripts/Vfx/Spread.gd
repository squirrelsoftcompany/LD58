extends MultiMeshInstance3D

enum Vars {POP,CRIM}

@export var radial_orientation : bool = false
@export var nb_max : int = 10
@export var watched_variable : Vars
@export var min_range : float
@export var max_range : float

func _ready():
	GlobalEventHolder.loopEnd.connect(_update)
	multimesh.instance_count = nb_max
	var offset = 2*PI/nb_max
	var dir : float =0
	for i in multimesh.instance_count:
		dir += offset
		var pos : Vector3 = Vector3(cos(dir),0.15,sin(dir)) * randf_range(min_range,max_range)
		var transfo : Transform3D = Transform3D(Basis.IDENTITY,pos)
		if radial_orientation:
			transfo = transfo.looking_at((pos-Vector3.UP)*2)
		else:
			transfo = transfo.rotated(Vector3.UP,randf_range(0,2*PI))
		multimesh.set_instance_transform(i,transfo)
	_update()

func _update():
	if watched_variable == Vars.POP:
		multimesh.visible_instance_count = $"../..".population
	else:
		multimesh.visible_instance_count = $"../..".crimeRate/2
