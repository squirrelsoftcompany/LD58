extends MultiMeshInstance3D

enum Vars {POP,CRIM,TREES}

@export var radial_orientation : bool = false
@export var nb_max : int = 10
@export var watched_variable : Vars
@export var min_range : float
@export var max_range : float
@export var min_offset : float = 1

var loic : RayCast3D
var first : bool = true

func _ready():
	loic = get_tree().get_first_node_in_group("SpaceForce")
	GlobalEventHolder.loopEnd.connect(_update)
	innit()
	if watched_variable == Vars.TREES:
		multimesh.visible_instance_count = -1

func innit():
	multimesh.instance_count = nb_max
	var offset = 2*PI/nb_max
	if offset < min_offset : offset = min_offset
	var dir : float =0
	for i in multimesh.instance_count:
		dir += offset
		var pos : Vector3 = Vector3(cos(dir),0,sin(dir))
		loic.position.x = pos.x
		loic.position.z = pos.z
		loic.target_position = pos + global_position -loic.position -Vector3.UP
		loic.force_raycast_update()
		var j : int = 0
		while loic.is_colliding():
			var nudged_dir : float = dir + (offset*(pow(-1,j))/5)*j
			pos = Vector3(cos(nudged_dir),0,sin(nudged_dir))
			loic.position.x = pos.x
			loic.position.z = pos.z
			loic.target_position = pos + global_position - loic.position -Vector3.UP
			loic.force_raycast_update()
			j += 1
		pos *= randf_range(min_range,max_range)
		var transfo : Transform3D = Transform3D(Basis.IDENTITY,pos+Vector3(0,0.15,0))
		if radial_orientation:
			transfo = transfo.looking_at((pos*2)-Vector3.UP)
		else:
			transfo = transfo.rotated(Vector3.UP,randf_range(0,2*PI))
		multimesh.set_instance_transform(i,transfo)
	_update()

func _update():
	if watched_variable == Vars.POP :
		multimesh.visible_instance_count = $"../..".population
	elif watched_variable == Vars.CRIM:
		multimesh.visible_instance_count = $"../..".crimeRate/2
