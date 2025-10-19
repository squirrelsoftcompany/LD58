extends Node3D

@export var map : PackedScene 

func _ready():
	GlobalEventHolder.gameOver.connect(game_over)
	add_child(map.instantiate())

func game_over():
	get_child(0).queue_free()
	add_child(map.instantiate())
