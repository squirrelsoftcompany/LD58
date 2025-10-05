extends Place
class_name City


func _enter_tree():
	generateCity();

func get_place_type() -> String:
	return "City"

func generateCity() -> void:
	generatePlace();
	pass
