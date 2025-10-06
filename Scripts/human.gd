extends Node3D
class_name Human

enum BodyState {ALIVE,DEAD}

@export var pv : int
@export var speed : float
@export var weapon : Weapon
@export var cooldown_hit: float = 1.5

var max_pv : int
var foos: Array[Node3D] = []
var can_hit: bool = true
var hit_timer: Timer
var target_foo : Human
var move_tween: Tween

var state: BodyState = BodyState.ALIVE

func set_weapon(pWeapon : Weapon):
	weapon = pWeapon
	
func heal():
	state = BodyState.ALIVE
	pv = max_pv

func try_to_hit(human : Human) -> void:
	if can_hit:
		print("BONK")
		human.take_damage(weapon.get_weapon_damage())
		can_hit = false
		hit_timer.start()

func take_damage(damage: int):
	pv = pv - damage
	if pv <= 0:
		die()

func die() -> void:
	if state == BodyState.DEAD:
		return
	state = BodyState.DEAD
	_stop_tween()
	# Death animation
	var tween = create_tween()
	tween.tween_property(
		self,
		"rotation_degrees",
		Vector3(90, rotation_degrees.y, rotation_degrees.z),
		0.8
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func get_closeset_foo(reference_position: Vector3) -> Node3D:
	var closest: Node3D = null
	var min_dist: float = INF
	
	for obj in foos:
		if obj.state == BodyState.DEAD: #Ignore dead foos
			continue
		var dist = obj.global_transform.origin.distance_to(reference_position)
		if dist < min_dist:
			min_dist = dist
			closest = obj
	return closest

func get_foo_to_bonk(reference_position: Vector3) -> Human:
	var target = get_closeset_foo(reference_position)
	if target:
		var dist = target.global_transform.origin.distance_to(reference_position)
		if dist <= weapon.get_weapon_range():
			return target
	return null

func _on_cooldown_finished() -> void:
	can_hit = true

func _stop_tween() -> void:
	if move_tween and move_tween.is_running():
		move_tween.kill()
