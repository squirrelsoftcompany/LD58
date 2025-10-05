extends Human
class_name Guard

var foos: Array[Bandit] = []
var at_range_foo: Array[Node3D] = []
var target_foo : Bandit

var can_hit: bool = true
var hit_timer: Timer

func generate() -> void:
	pass

func _ready():
	#  Default weapon for test
	var newWeapon = Weapon.new()
	newWeapon.weapon_damage = 15
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
			try_to_hit(target_foo)
		else:
			move()

func set_weapon(pWeapon : Weapon):
	weapon = pWeapon


func move() -> void:
	var enemy = get_closeset_foo(global_transform.origin)
	if enemy == null:
		return
		
	var weapon_range = weapon.get_weapon_range()
	var start_pos = global_transform.origin
	
	var foo_pos = enemy.global_transform.origin
	var dir = (foo_pos - start_pos).normalized()
	var target_pos = foo_pos - (dir * weapon_range *0.95)
	
	var tween = create_tween()
	var travel_time = start_pos.distance_to(target_pos) / speed
	tween.tween_property(self, "global_transform:origin", target_pos, travel_time).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func _on_node_added(node: Node) -> void:
	if node.is_in_group("bandit"):
		foos.append(node)

func _on_node_removed(node: Node) -> void:
	if node.is_in_group("bandit"):
		foos.erase(node)

func try_to_hit(bandit : Bandit) -> void:
	if can_hit:
		print("BONK")
		bandit.take_damage(weapon.get_weapon_damage())
		can_hit = false
		hit_timer.start()

func _on_cooldown_finished() -> void:
	can_hit = true

func get_foo_to_bonk(reference_position: Vector3) -> Bandit:
	var target = get_closeset_foo(reference_position)
	if target:
		var dist = target.global_transform.origin.distance_to(reference_position)
		if dist <= weapon.get_weapon_range():
			return target
	return null
	
func get_closeset_foo(reference_position: Vector3) -> Bandit:
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
