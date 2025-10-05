extends Node3D
class_name Human

enum BodyState {ALIVE,DEAD}

@export var pv : int
@export var speed : float
@export var weapon : Weapon
@export var cooldown_hit: float = 1.5

var state: BodyState = BodyState.ALIVE


func take_damage(damage: int):
	pv = pv - damage
	if pv <= 0:
		die()

func die() -> void:
	if state == BodyState.DEAD:
		return
	state = BodyState.DEAD
	# Death animation
	var tween = create_tween()
	tween.tween_property(
		self,
		"rotation_degrees",
		Vector3(90, rotation_degrees.y, rotation_degrees.z),
		0.8
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
