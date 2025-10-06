extends Node

enum AmbushState {INIT,START,RUNNING,END}

var caravan: Caravan
@export var spawn_distance: float = 5.0
@export var guard_distance: float = 3.0 
@export var spread_radius: float = 4.0
@export var direction: Vector3 = Vector3.BACK
@export var bandit_scene: PackedScene

var camera: Camera3D
@export var camera_move_duration: float = 1.5
@export var camera_side_offset: float = 10.0
@export var camera_forward_offset: float = 2.0
@export var camera_height_offset: float = 10.0

var bandits_list: Array[Node3D] = [] 
var state = AmbushState.INIT
var original_cam_transform: Transform3D

func _ready():
	GlobalEventHolder.connect("startAmbush", Callable(self, "init_ambush"))
	for node in get_tree().get_nodes_in_group("caravan"):
		caravan = node
	camera = get_viewport().get_camera_3d()

func _process(_delta: float) -> void:
	if state == AmbushState.INIT:
		return
	if state == AmbushState.START:
		var ambush_finish = true
		for bandit in bandits_list:
			if bandit.state == Bandit.BodyState.ALIVE:
				ambush_finish = false
		if ambush_finish:
			end_ambush()
	
func init_ambush(nb_bandit : int):
	var caravan_pos = caravan.global_transform.origin
	var forward_dir = direction.normalized()
	
	#Setup camera view
	original_cam_transform = camera.global_transform
	_focus_camera_on_ambush()
	
	#Bandits spawn and placement
	for i in range(nb_bandit):
		var lateral_offset = Vector3(
			randf_range(-spread_radius, spread_radius),
			0.0,
			randf_range(-spread_radius * 0.2, spread_radius * 0.2)
		)
		var spawn_pos = caravan_pos + forward_dir * spawn_distance + lateral_offset
	
		# Instantiate bandit
		var bandit = bandit_scene.instantiate()
		add_child(bandit)
		bandit.global_transform.origin = spawn_pos
		bandit.look_at(caravan_pos, Vector3.UP)
		bandits_list.append(bandit)
	
	#Guards placement
	var guards = caravan.get_guards()
	for guard in guards:
		var lateral_offset = Vector3(
			randf_range(-spread_radius * 0.5, spread_radius * 0.5),
			0.0,
			randf_range(-spread_radius * 0.25, spread_radius * 0.25)
		)
		var guard_pos = caravan_pos + forward_dir * guard_distance + lateral_offset
		guard.global_transform.origin = guard_pos
		guard.look_at(caravan_pos, Vector3.UP)
	state = AmbushState.START

func end_ambush():
	state = AmbushState.END
	# Return camera to original view
	var tween = create_tween()
	tween.tween_property(camera, "global_transform", original_cam_transform, camera_move_duration)
	queue_free()
	
func _focus_camera_on_ambush():
	var caravan_transform = caravan.global_transform
	
	var horizontal_offset = (-caravan_transform.basis.x * camera_side_offset) + (-caravan_transform.basis.z * 1)
	
	# position finale de la caméra
	var cam_target_pos = caravan_transform.origin + horizontal_offset + Vector3.UP * camera_height_offset

	# rotation finale
	var final_basis = Basis.looking_at(caravan_transform.origin - cam_target_pos, Vector3.UP)
	var final_transform = Transform3D(final_basis, cam_target_pos)

	var tween = create_tween()
	tween.tween_property(camera, "global_transform", final_transform, camera_move_duration)
