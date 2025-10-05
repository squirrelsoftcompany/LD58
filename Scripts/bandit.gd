extends Human
class_name Bandit


func _process(_delta: float) -> void:
	flee()

# JUST FOR TEST !!!!
func flee():
	var tween = create_tween()
	var foo_pos = global_transform.origin
	var dir = Vector3.LEFT
	var target_pos = foo_pos - dir
	
	var travel_time = 10
	tween.tween_property(self, "global_transform:origin", target_pos, travel_time).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
