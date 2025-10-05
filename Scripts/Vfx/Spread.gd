extends MultiMeshInstance3D

@export var radial_orientation : bool = false
@export var angle : float = 0 ## if radial orientation true
@export var nb_max : int = 10
@export var watched_variable : String
@export var min_range : float
@export var max_range : float

var meshes : Array

func _ready():
	pass
