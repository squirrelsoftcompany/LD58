extends Node3D

@export var map : PackedScene 

var cycling : bool = false

func _ready():
	GlobalEventHolder.gameOver.connect(game_over)
	add_child(map.instantiate())

func _process(_delta):
	if cycling:
		add_child(map.instantiate())
		cycling = false

func game_over():
	get_child(0).queue_free()
	cycling = true
	
