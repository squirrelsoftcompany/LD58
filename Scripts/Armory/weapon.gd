extends Node
class_name Weapon

@export var weapon_name : String
@export var weapon_damage : int
@export var weapon_range : float

func get_weapon_damage() -> int:
	return weapon_damage

func get_weapon_range() -> float:
	return weapon_range
