extends Human
class_name Bandit

var target_caravan: Node3D
var has_loot = false


func _ready():
	#  Default weapon for test
	var newWeapon = Weapon.new()
	newWeapon.weapon_damage = 15
	newWeapon.weapon_range = 0.3
	set_weapon(newWeapon)
	# Found foo
	for node in get_tree().get_nodes_in_group("guard"):
		if node is Guard:
			foos.append(node)
	for node in get_tree().get_nodes_in_group("caravan"):
		target_caravan = node
	get_tree().connect("node_added", Callable(self, "_on_node_added"))
	get_tree().connect("node_removed", Callable(self, "_on_node_removed"))
	# Hit timer
	hit_timer = Timer.new()
	hit_timer.wait_time = cooldown_hit
	hit_timer.one_shot = true
	hit_timer.connect("timeout", Callable(self, "_on_cooldown_finished"))
	add_child(hit_timer)
	
	
func _process(_delta: float) -> void:
	# First hit ennemies at range
	if state != BodyState.DEAD and weapon:
		target_foo = get_foo_to_bonk(global_transform.origin)
		if target_foo:
			_stop_tween()
			try_to_hit(target_foo)
		elif close_to_caravan() and not has_loot:
			#Loot the caravan
			_stop_tween()
			loot()
		else:
			#Go to the caravan
			move()
		try_vanish()

func _on_node_added(node: Node) -> void:
	if node.is_in_group("guard"):
		foos.append(node)
	if node.is_in_group("caravan"):
		target_caravan = node

func _on_node_removed(node: Node) -> void:
	if node.is_in_group("guard"):
		foos.erase(node)
		
func move() -> void:
	var caravan = target_caravan
	if caravan == null:
		return
		
	var weapon_range = weapon.get_weapon_range()
	var start_pos = global_transform.origin
	
	var caravan_pos = caravan.global_transform.origin
	var dir = (caravan_pos - start_pos).normalized()
	# No loot ? Get it. Got the loot yet? Run
	var target_pos
	if not has_loot:
		target_pos = caravan_pos - (dir * weapon_range *2.0)
	else :
		target_pos = -dir * 200
	
	_stop_tween()
	move_tween = create_tween()
	var travel_time = start_pos.distance_to(target_pos) / speed
	move_tween.tween_property(self, "global_transform:origin", target_pos, travel_time).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func loot() -> void:
	#target_caravan.take_loot()
	has_loot = true
	
func try_vanish():
	if has_loot and target_caravan:
		var pos = global_transform.origin
		var caravan_pos = target_caravan.global_transform.origin
		if (pos - caravan_pos).length() > 100.0:
			die()
	
func close_to_caravan() -> bool:
	var caravan = target_caravan
	if caravan == null:
		return false
	var start_pos = global_transform.origin
	var caravan_pos = caravan.global_transform.origin
	return ((start_pos - caravan_pos).length() < 1.0)
