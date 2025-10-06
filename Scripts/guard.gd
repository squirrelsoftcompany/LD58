extends Human
class_name Guard

var at_range_foo: Array[Node3D] = []


func generate() -> void:
	pass

func _ready():
	#  Default weapon for test
	var newWeapon = Weapon.new()
	newWeapon.weapon_damage = 50
	newWeapon.weapon_range = 0.3
	set_weapon(newWeapon)
	# Found foo
	for node in get_tree().get_nodes_in_group("bandit"):
		if node is Bandit:
			foos.append(node)
	get_tree().connect("node_added", Callable(self, "_on_node_added"))
	get_tree().connect("node_removed", Callable(self, "_on_node_removed"))
	# Hit timer
	hit_timer = Timer.new()
	hit_timer.wait_time = cooldown_hit
	hit_timer.one_shot = true
	hit_timer.connect("timeout", Callable(self, "_on_cooldown_finished"))
	add_child(hit_timer)

		
func _process(_delta: float) -> void:
	if state != BodyState.DEAD and weapon:
		target_foo = get_foo_to_bonk(global_transform.origin)
		if target_foo:
			_stop_tween()
			try_to_hit(target_foo)
		else:
			move()


func move() -> void:
	var enemy = get_closeset_foo(global_transform.origin)
	if enemy == null:
		return
		
	var weapon_range = weapon.get_weapon_range()
	var start_pos = global_transform.origin
	
	var foo_pos = enemy.global_transform.origin
	var dir = (foo_pos - start_pos).normalized()
	var target_pos = foo_pos - (dir * weapon_range *0.95)
	
	_stop_tween()
	move_tween = create_tween()
	var travel_time = start_pos.distance_to(target_pos) / speed
	move_tween.tween_property(self, "global_transform:origin", target_pos, travel_time).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func _on_node_added(node: Node) -> void:
	if node.is_in_group("bandit"):
		foos.append(node)

func _on_node_removed(node: Node) -> void:
	if node.is_in_group("bandit"):
		foos.erase(node)



	
